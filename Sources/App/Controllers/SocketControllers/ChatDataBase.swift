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
    
    func getChatContacts(chat:Chat)->Future<Chat.ChatContacts> {
        return dataBase.getChatContacts(userId: self.userId, chat: chat)
    }
    
    func getChatContacts(chatId:Int)->Future<Chat.ChatContacts> {
        return dataBase.getChatContacts(userId: self.userId, chatId: chatId)
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
    
    func getPromise<T>(type:T.Type)->Promise<T>{
        let promise = self.req.eventLoop.newPromise(type.self)
        return promise
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
    
    fileprivate func getChatContacts(userId:Int,chat:Chat)->Future<Chat.ChatContacts> {
        return performQuery(query: { conn in
            return try Chat.getChatContacts(userId: userId, chat: chat, conn: conn)
        })
    }
    
    fileprivate func getChatContacts(userId:Int,chatId:Int)->Future<Chat.ChatContacts> {
        return performQuery(query: { conn in
            return Chat.getChatContacts(userId: userId, chatId: chatId, conn: conn)
        })
    }

    fileprivate func getUserChats(userId:Int)->Future<[Chat]>{
        return performQuery(query: { conn in
            return Chat.userChats(userId: userId, conn: conn)
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
