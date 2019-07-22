//
//  ChatDataBase.swift
//  App
//
//  Created by Amir Hossein on 3/29/19.
//

import Vapor
import FluentPostgreSQL


class ChatRequestInfo {
    let userId:Int
    let dataBase:ChatDataBase
    
    init(userId:Int,dataBase:ChatDataBase) {
        self.userId=userId
        self.dataBase=dataBase
    }
    
    func getChatContacts(chat:Chat,withBlocked:Bool = false)->Future<Chat.ChatContacts> {
        return dataBase.getChatContacts(userId: self.userId, chat: chat, withBlocked: withBlocked)
    }
    
    func getChatContacts(chatId:Int,withBlocked:Bool = false)->Future<Chat.ChatContacts> {
        return dataBase.getChatContacts(userId: self.userId, chatId: chatId, withBlocked: withBlocked)
    }
    
    func getUserBlockedChats()->Future<[ChatBlock]>{
        return dataBase.getUserBlockedChats(userId: self.userId)
    }
    
    func getUserChats()->Future<[Chat]>{
        return dataBase.getUserChats(userId: self.userId)
    }
}

class ChatDataBase {
    private var req:Request
    private var withPooledConnection:Bool
    
    init(req:Request,withPooledConnection:Bool=false) {
        self.req=req
        self.withPooledConnection=withPooledConnection
    }
    
    func getRequest() throws -> Request {
        if !withPooledConnection {
            return req
        } else {
            throw Constants.errors.requestIsInaccessible
        }
    }
    
    func performQuery<T>(query: @escaping (DatabaseConnectable) throws ->Future<T>)->Future<T> {
        
        if !withPooledConnection {
            
            do {
                return try query(req)
            } catch {
                return req.eventLoop.newFailedFuture(error: error)
            }
            
        } else {
            return req.withPooledConnection(to: .psql, closure: { conn in
                return try query(conn)
            })
        }
        
    }
    
    func isTokenAuthenticated(bearerAuthorization:BearerAuthorization)->Future<Token?>{
        return performQuery(query: { conn in
            return Token.authenticate(using: bearerAuthorization, on: conn)
        })
    }
    
    func isUserAuthenticated(token:Token)->Future<User?> {
        return performQuery(query: { conn in
            return User.authenticate(token: token, on: conn)
        })
    }
    
    fileprivate func getChatContacts(userId:Int,chat:Chat,withBlocked:Bool)->Future<Chat.ChatContacts> {
        return performQuery(query: { conn in
            return try Chat.getChatContacts(userId: userId, chat: chat, conn: conn, withBlocked: withBlocked)
        })
    }
    
    fileprivate func getChatContacts(userId:Int,chatId:Int,withBlocked:Bool)->Future<Chat.ChatContacts> {
        return performQuery(query: { conn in
            return Chat.getChatContacts(userId: userId, chatId: chatId, conn: conn, withBlocked: withBlocked)
        })
    }

    fileprivate func getUserChats(userId:Int)->Future<[Chat]>{
        return performQuery(query: { conn in
            return Chat.userChats(userId: userId, conn: conn)
        })
    }
    
    fileprivate func getUserBlockedChats(userId:Int)->Future<[ChatBlock]>{
        return performQuery(query: { conn in
            return ChatBlock.allBlockedChat(userId: userId, conn: conn)
        })
    }
    
    func getTextMessage(id:Int)->Future<TextMessage?>{
        return performQuery(query: { conn in
            return TextMessage.find(id, on: conn)
        })
    }
    
    func getTextMessages(chat:Chat,beforeId:Int?)->Future<[TextMessage]>{
        return performQuery(query: { conn in
            return try TextMessage.getTextMessages(chat: chat, beforeId: beforeId, conn: conn)
        })
    }
    
    func saveMessage(message:TextMessage) -> Future<TextMessage> {
        return performQuery(query: { conn in
            return message.save(on: conn)
        })
    }
    
    func getChat(chatId:Int)->Future<Chat?>{
        return performQuery(query: { conn in
            return Chat.find(chatId, on: conn)
        })
    }
    
    
    func getContactProfile(contactId:Int)->Future<User?> {
        return performQuery(query: { conn in
            return User.find(contactId, on: conn)
        })
    }
    
    func calculateNumberOfNotifications(notificationUserId:Int,chatId:Int)->Future<Int>{
        return performQuery(query: { conn in
            return TextMessage.calculateNumberOfNotifications(userId: notificationUserId, chatId: chatId, conn: conn)
        })
    }
    
    func findChatNotification(notificationUserId:Int,chatId:Int)->Future<ChatNotification?> {
        return performQuery(query: { conn in
            return ChatNotification.find(userId: notificationUserId, chatId: chatId, conn: conn)
        })
    }
    
    func saveChatNotification(chatNotification:ChatNotification) -> Future<ChatNotification> {
        return performQuery(query: { conn in
            return chatNotification.save(on: conn)
        })
    }
    
}
