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
    static func findChat(userId:Int,contactId:Int,req:Request) -> Future<Chat?> {
        return Chat.query(on: req).group(.or) { query in
            query.group(.and, closure: { query in
                query.filter(\.firstId == userId).filter(\.secondId == contactId)
            }).group(.and, closure: { query in
                query.filter(\.firstId == contactId).filter(\.secondId == userId)
            })
            }.first()
    }
    
    static func userChats(userId:Int,req:Request) -> Future<[Chat]> {
        return Chat.query(on: req).group(.or) { query in
            query.filter(\.firstId == userId).filter(\.secondId == userId)
        }.all()
    }
}

extension Chat {
    class ChatSenderReceiver {
        var senderId:Int
        var receiverId:Int
        init(senderId:Int,receiverId:Int) {
            self.senderId=senderId
            self.receiverId=receiverId
        }
    }
    
    static func getChatSenderReceiver(userId:Int,req:Request,chatId:Int)->Future<ChatSenderReceiver?> {
        return Chat.find(chatId, on: req).map{ chat -> ChatSenderReceiver? in
            guard let chat = chat else {
                return nil
            }
            guard chat.firstId == userId || chat.secondId == userId else {
                return nil
            }
            if chat.firstId == userId {
                return ChatSenderReceiver(senderId: chat.firstId, receiverId: chat.secondId)
            }
            return ChatSenderReceiver(senderId: chat.secondId, receiverId: chat.firstId)
        }
    }
}


extension Chat : Migration {}
extension Chat : Content {}
extension Chat : Parameter {}
