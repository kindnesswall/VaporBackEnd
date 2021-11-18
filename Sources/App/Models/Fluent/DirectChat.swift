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
    
    @ID(custom: .id)
    var id: Int?
    
    @Field(key: "userId")
    var userId:Int
    
    @Field(key: "contactId")
    var contactId: Int
    
    @Field(key: "userIsBlocked")
    var userIsBlocked: Bool
    
    @Field(key: "contactIsBlocked")
    var contactIsBlocked: Bool
    
    @Field(key: "userNotification")
    var userNotification:Int
    
    @Field(key: "contactNotification")
    var contactNotification:Int
    
    @Children(for: \.$chat)
    var textMessages: [TextMessage]
    
    init() {}
    
    init(userId:Int, contactId: Int) {
        self.userId = userId
        self.contactId = contactId
        
        self.userIsBlocked = false
        self.contactIsBlocked = false
        self.userNotification = 0
        self.contactNotification = 0
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
    
    static func findOrFail(authId: Int, chatId: Int, on conn: Database) -> EventLoopFuture<ContactMessage> {
        return find(chatId, on: conn).flatMapThrowing { item in
            guard let item = item else {
                throw Abort(.chatNotFound)
            }
            return try item.castFor(authId: authId)
        }
    }
    
    static func find(userId: Int, contactId: Int, on conn: Database) -> EventLoopFuture<ContactMessage?> {
        return _find(userId: userId, contactId: contactId, on: conn).first().flatMapThrowing { item in
            return try item?.castFor(authId: userId)
        }
    }
    
    static func findOrCreate(userId: Int, contactId: Int, on conn: Database) -> EventLoopFuture<ContactMessage> {
        let input = DirectChat(userId: userId, contactId: contactId)
        return _findOrCreate(input: input, on: conn).flatMapThrowing { item in
            return try item.castFor(authId: userId)
        }
        
    }
}

extension DirectChat {
    
    private static func fetch(textMessages: ChildrenProperty<DirectChat, TextMessage>, beforeId: Int?, on conn: Database) -> EventLoopFuture<[TextMessage]> {
        
        let query = textMessages.query(on: conn)
        
        if let beforeId = beforeId {
            query.filter(\.$id < beforeId)
        }
        let maximumCount = Constants.maxFetchCount
        
        //TODO: For performance issue
        //      is sort(\.id, .descending) necessary?
        
        return query.sort(\.$id, .descending).range(0..<maximumCount).all()
        
    }
    
    
    static func fetchTextMessages(beforeId: Int?, authId: Int, chatId: Int, on db: Database) -> EventLoopFuture<ContactMessage> {
        return find(chatId, on: db).flatMap { chat in
            
            guard let chat = chat else {
                return db.makeFailedFuture(.chatNotFound)
            }
            guard chat.isAuthenticated(authId: authId) else {
                return db.makeFailedFuture(.unauthorizedRequest)
            }
            
            return fetch(textMessages: chat.$textMessages, beforeId: beforeId, on: db).flatMapThrowing { textMessages in
                
                let item = try chat.castFor(authId: authId)
                item.textMessages = textMessages
                return item
                
            }
        }
    }
}

extension DirectChat: FindOrCreatable {
    
    static func _findQuery(input: DirectChat, on conn: Database) -> QueryBuilder<DirectChat> {
        return _find(userId: input.userId, contactId: input.contactId, on: conn)
    }
    
    //TODO:
    // - now (userId, contactId) pairs are unique.
    // - however, (1,2) and (2,1) may be considered valid in the database, which is not valid.
    // - check if it happens and if it happens:
    //     - how rare is it happens?
    //     - what is its consequences?
    static private func _find(userId: Int, contactId: Int, on conn: Database) -> QueryBuilder<DirectChat> {
        return query(on: conn).group(.or) { query in
            query.group(.and) { query in
                query.filter(\.$userId == userId)
                    .filter(\.$contactId == contactId)
            }.group(.and) { query in
                query.filter(\.$userId == contactId)
                    .filter(\.$contactId == userId)
            }
        }
    }
}

extension DirectChat {
    static func userChats(blocked: Bool, authId: Int, on req: Request) -> EventLoopFuture<[ContactMessage]> {
        let onUsers = query(on: req.db)
            .filter(\.$userId == authId)
            .filter(\.$contactIsBlocked == blocked)
            .join(User.self, on: \DirectChat.$contactId == \User.$id)
            .all()
        let onContacts = query(on: req.db)
            .filter(\.$contactId == authId)
            .filter(\.$userIsBlocked == blocked)
            .join(User.self, on: \DirectChat.$userId == \User.$id)
            .all()
        
        return onUsers.and(onContacts).flatMapThrowing {
            return try ($0.0 + $0.1).map {
                let item = try $0.castFor(authId: authId)
                item.contactProfile = try $0
                    .joined(User.self)
                    .userProfile(req: req)
                return item
            }
        }
    }
}

extension DirectChat {
    static func set(notification: Int, receiverId: Int, chatId: Int, on db: Database) -> EventLoopFuture<HTTPStatus> {
        
        return find(chatId, on: db).flatMap { item in
            guard let item = item else {
                return db.makeFailedFuture(.chatNotFound)
            }
            switch receiverId {
            case item.userId:
                item.userNotification = notification
            case item.contactId:
                item.contactNotification = notification
            default:
                return db.makeFailedFuture(.unauthorizedRequest)
            }
            return item.save(on: db).transform(to: .ok)
        }
    }
}

extension DirectChat {
    static func set(block: Bool, authId: Int, chatId: Int, on db: Database) -> EventLoopFuture<ChatBlock> {
        
        return find(chatId, on: db).flatMap { item in
            
            guard let item = item else {
                return db.makeFailedFuture(.chatNotFound)
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
                return db.makeFailedFuture(.unauthorizedRequest)
            }
            
            return item.save(on: db).transform(to:
                ChatBlock(chatId: chatId, blockedUserId: blockedUserId, byUserId: authId)
            )
        }
    }
}


//extension DirectChat : Migration {}
extension DirectChat : Content {}


