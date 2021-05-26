//
//  DirectChat.swift
//  App
//
//  Created by Amir Hossein on 5/19/20.
//

import Vapor
import Fluent

final class DirectChat: Model {
    
    static let schema = "DirectChat"
    
    var id: Int?
    var userId:Int
    var contactId: Int
    var userIsBlocked: Bool = false
    var contactIsBlocked: Bool = false
    var userNotification:Int = 0
    var contactNotification:Int = 0
    
    init() {}
    
    init(userId:Int, contactId: Int) {
        self.userId = userId
        self.contactId = contactId
    }
}

extension DirectChat {
    
    func getId() throws -> Int {
        guard let id = self.id else {
            throw Abort(.nilChatId)
        }
        return id
    }
}

extension DirectChat {
    
    private func castFor(authId: Int) throws -> ContactMessage {
        
        let chatId = try getId()
        
        let chat: ChatContacts
        let blockStatus: BlockStatus
        let notification: Int
        
        switch authId {
            
        case self.userId:
            
            chat = ChatContacts(chatId: chatId, userId: userId, contactId: contactId)
            blockStatus = BlockStatus(userIsBlocked: userIsBlocked, contactIsBlocked: contactIsBlocked)
            notification = userNotification
            
        case self.contactId:
            
            chat = ChatContacts(chatId: chatId, userId: contactId, contactId: userId)
            blockStatus = BlockStatus(userIsBlocked: contactIsBlocked, contactIsBlocked: userIsBlocked)
            notification = contactNotification
            
        default:
            throw Abort(.unauthorizedRequest)
        }
        
        return ContactMessage(chat: chat, notificationCount: notification, blockStatus: blockStatus)
        
    }
    
    private func isAuthenticated(authId: Int) -> Bool {
        switch authId {
            case self.userId, self.contactId:
            return true
        default:
            return false
        }
    }
}

extension DirectChat {
    var textMessages : Children<DirectChat,TextMessage> {
        return children(\.chatId)
    }
}

extension DirectChat {
    
    static func findOrFail(authId: Int, chatId: Int, on conn: Database) -> EventLoopFuture<ContactMessage> {
        return find(chatId, on: conn).map { item in
            guard let item = item else {
                throw Abort(.chatNotFound)
            }
            return try item.castFor(authId: authId)
        }
    }
    
    static func find(userId: Int, contactId: Int, on conn: Database) -> EventLoopFuture<ContactMessage?> {
        return _find(userId: userId, contactId: contactId, on: conn).first().map { item in
            return try item?.castFor(authId: userId)
        }
    }
    
    static func findOrCreate(userId: Int, contactId: Int, on conn: Database) -> EventLoopFuture<ContactMessage> {
        let input = DirectChat(userId: userId, contactId: contactId)
        return _findOrCreate(input: input, on: conn).map { item in
            return try item.castFor(authId: userId)
        }
        
    }
}

extension DirectChat {
    
    private static func fetch(textMessages: Children<DirectChat, TextMessage>, beforeId: Int?, on conn: Database) throws -> EventLoopFuture<[TextMessage]> {
        
        let query = try textMessages.query(on: conn)
        
        if let beforeId = beforeId {
            query.filter(\.id < beforeId)
        }
        let maximumCount = Constants.maxFetchCount
        
        //TODO: For performance issue
        //      is sort(\.id, .descending) necessary?
        
        return query.sort(\.id, .descending).range(0..<maximumCount).all()
        
    }
    
    
    static func fetchTextMessages(beforeId: Int?, authId: Int, chatId: Int, on conn: Database) -> EventLoopFuture<ContactMessage> {
        return find(chatId, on: conn).flatMap { chat in
            
            guard let chat = chat else {
                throw Abort(.chatNotFound)
            }
            guard chat.isAuthenticated(authId: authId) else {
                throw Abort(.unauthorizedRequest)
            }
            
            return try fetch(textMessages: chat.textMessages, beforeId: beforeId, on: conn).map({ textMessages in
                
                let item = try chat.castFor(authId: authId)
                item.textMessages = textMessages
                return item
                
            })
        }
    }
}

extension DirectChat: FindOrCreatable {
    
    static func _findQuery(input: DirectChat, on conn: Database) -> QueryBuilder<PostgreSQLDatabase, DirectChat> {
        return _find(userId: input.userId, contactId: input.contactId, on: conn)
    }
    
    static private func _find(userId: Int, contactId: Int, on conn: Database) -> QueryBuilder<PostgreSQLDatabase, DirectChat> {
        return query(on: conn).group(.or) { query in
            query.group(.and, closure: { query in
                query.filter(\.userId == userId).filter(\.contactId == contactId)
            }).group(.and, closure: { query in
                query.filter(\.userId == contactId).filter(\.contactId == userId)
            })
        }
    }
}

extension DirectChat {
    static func userChats(blocked: Bool, userId: Int, on req: Request) -> EventLoopFuture<[ContactMessage]> {
        let onUsers = query(on: req)
            .filter(\.userId == userId)
            .filter(\.contactIsBlocked == blocked)
            .join(\User.id, to: \DirectChat.contactId)
            .alsoDecode(User.self).all()
        let onContacts = query(on: req)
            .filter(\.contactId == userId)
            .filter(\.userIsBlocked == blocked)
            .join(\User.id, to: \DirectChat.userId)
            .alsoDecode(User.self).all()
        return onUsers.and(onContacts).map { onUsers, onContacts in
            let merged = merge(onUsers: onUsers, onContacts: onContacts)
            return try merged.map { each in
                let item = try each.0.castFor(authId: userId)
                item.contactProfile = try each.1.userProfile(req: req)
                return item
            }
        }
    }
    
    private static func merge(onUsers: [(DirectChat, User)], onContacts: [(DirectChat, User)]) -> [(DirectChat, User)] {
        var merged = [(DirectChat, User)]()
        merged.append(contentsOf: onUsers)
        merged.append(contentsOf: onContacts)
        return merged
    }
}

extension DirectChat {
    static func set(notification: Int, receiverId: Int, chatId: Int, on conn: Database) -> EventLoopFuture<HTTPStatus> {
        return find(chatId, on: conn).flatMap { item in
            guard let item = item else {
                throw Abort(.chatNotFound)
            }
            switch receiverId {
            case item.userId:
                item.userNotification = notification
            case item.contactId:
                item.contactNotification = notification
            default:
                throw Abort(.unauthorizedRequest)
            }
            return item.save(on: conn).transform(to: .ok)
        }
    }
}

extension DirectChat {
    static func set(block: Bool, authId: Int, chatId: Int, on conn: Database) -> EventLoopFuture<ChatBlock> {
        
        return find(chatId, on: conn).flatMap { item in
            
            guard let item = item else {
                throw Abort(.chatNotFound)
            }
            
            let blockedUserId: Int
            switch authId {
            case item.userId:
                item.contactIsBlocked = block
                blockedUserId = item.contactId
            case item.contactId:
                item.userIsBlocked = block
                blockedUserId = item.userId
            default:
                throw Abort(.unauthorizedRequest)
            }
            
            return item.save(on: conn).transform(to:
                ChatBlock(chatId: chatId, blockedUserId: blockedUserId, byUserId: authId)
            )
        }
    }
}


//extension DirectChat : Migration {}
extension DirectChat : Content {}


