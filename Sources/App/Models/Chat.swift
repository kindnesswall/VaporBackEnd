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
    
    init(firstId:Int,secondId:Int) {
        self.firstId=firstId
        self.secondId=secondId
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
    
    static func isUserChat(userId:Int,chat:Chat)->Bool {
        if chat.firstId == userId || chat.secondId == userId {
            return true
        }
        return false
    }
}

extension Chat {
    class ChatContacts {
        var chat:Chat
        var userId:Int
        var contactId:Int
        init(chat:Chat,userId:Int,contactId:Int) {
            self.chat=chat
            self.userId=userId
            self.contactId=contactId
        }
    }
    
    static func getChatContacts(userId:Int,conn:DatabaseConnectable,chatId:Int)->Future<ChatContacts?> {
        return Chat.find(chatId, on: conn).map{ chat -> ChatContacts? in
            guard let chat = chat else {
                return nil
            }
            return Chat.getChatContacts(userId: userId, chat: chat)
            
        }
    }
    
    static func getChatContacts(userId:Int,chat:Chat)->ChatContacts? {
        
        guard isUserChat(userId: userId, chat: chat) else {
            return nil
        }
        if chat.firstId == userId {
            return ChatContacts(chat: chat, userId: chat.firstId, contactId: chat.secondId)
        }
        return ChatContacts(chat: chat, userId: chat.secondId, contactId: chat.firstId)
    }
    
}


extension Chat : Migration {}
extension Chat : Content {}
extension Chat : Parameter {}
