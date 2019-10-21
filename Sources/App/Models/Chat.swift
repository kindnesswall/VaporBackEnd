//
//  Chat.swift
//  App
//
//  Created by Amir Hossein on 3/13/19.
//

import Vapor
import FluentPostgreSQL


final class Chat : PostgreSQLModel {
    var id:Int?
    var firstId:Int
    var secondId:Int
    var firstIsBlocked:Bool = false
    var secondIsBlocked:Bool = false
    
    init(firstId:Int,secondId:Int) {
        self.firstId=firstId
        self.secondId=secondId
    }
    
    func getId() throws -> Int {
        guard let id = self.id else {
            throw Constants.errors.nilChatId
        }
        return id
    }
    
    func getIdFuture(req:Request) -> Future<Int> {
        guard let id = self.id else {
            return req.eventLoop.newFailedFuture(error: Constants.errors.nilChatId)
        }
        return req.eventLoop.newSucceededFuture(result: id)
    }
}

extension Chat {
    var textMessages : Children<Chat,TextMessage> {
        return children(\.chatId)
    }
}

extension Chat {
    static func findChat(userId:Int,contactId:Int,conn:DatabaseConnectable) -> Future<Chat?> {
        return Chat.query(on: conn).group(.or) { query in
            query.group(.and, closure: { query in
                query.filter(\.firstId == userId).filter(\.secondId == contactId)
            }).group(.and, closure: { query in
                query.filter(\.firstId == contactId).filter(\.secondId == userId)
            })
            }.first()
    }
    
    static func userChats(userId:Int,conn:DatabaseConnectable) -> Future<[Chat]> {
        return Chat.query(on: conn).group(.or) { query in
            query.filter(\.firstId == userId).filter(\.secondId == userId)
        }.all()
    }
    
    static func getChat(chatId:Int,conn:DatabaseConnectable) -> Future<Chat> {
        return Chat.find(chatId, on: conn).map { chat in
            guard let chat = chat else {
                throw Constants.errors.chatNotFound
            }
            return chat
        }
    }
    
}

extension Chat {
    final class ChatContacts: Content {
        var chatId:Int
        var userId:Int
        var contactId:Int
        init(chatId:Int,userId:Int,contactId:Int) {
            self.chatId=chatId
            self.userId=userId
            self.contactId=contactId
        }
    }
    
    func isUserChat(userId:Int)->Bool {
        if self.firstId == userId || self.secondId == userId {
            return true
        }
        return false
    }
    
    func getChatContacts(userId:Int) throws -> ChatContacts {
        
        guard self.isUserChat(userId: userId) else {
            throw Constants.errors.unauthorizedRequest
        }
        
        let chatId = try self.getId()
        
        if self.firstId == userId {
            return ChatContacts(chatId: chatId, userId: self.firstId, contactId: self.secondId)
        }
        return ChatContacts(chatId: chatId, userId: self.secondId, contactId: self.firstId)
    }
    
}

extension Chat {
    
    func setContactBlock(userId:Int , block:Bool, conn: DatabaseConnectable) throws -> Future<Chat> {
        
        guard self.isUserChat(userId: userId) else {
            throw Constants.errors.unauthorizedRequest
        }
        
        if userId == self.firstId {
            self.secondIsBlocked = block
        } else {
            self.firstIsBlocked = block
        }
        
        return self.save(on: conn)
        
    }
    
    func isChatUnblock() -> Bool {
        if !self.firstIsBlocked && !self.secondIsBlocked {
            return true
        }
        return false
    }
    
    func getChatBlockStatus(userId:Int) throws -> BlockStatus {
        
        guard self.isUserChat(userId: userId) else {
            throw Constants.errors.unauthorizedRequest
        }
        
        if userId == self.firstId {
            return BlockStatus(userIsBlocked: self.firstIsBlocked, contactIsBlocked: self.secondIsBlocked)
        }
        
        return BlockStatus(userIsBlocked: self.secondIsBlocked, contactIsBlocked: self.firstIsBlocked)
        
    }
}


extension Chat : Migration {}
extension Chat : Content {}
extension Chat : Parameter {}
