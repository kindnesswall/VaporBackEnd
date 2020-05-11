//
//  ChatInitializer.swift
//  App
//
//  Created by Amir Hossein on 5/10/20.
//

import Vapor

class ChatInitializer {
    
    func findOrCreateContacts(user: User, contact: User, on conn: DatabaseConnectable) throws -> Future<Chat.ChatContacts> {
        let userId = try user.getId()
        let contactId = try contact.getId()
        return try self.findOrCreateContacts(userId: userId, contactId: contactId, on: conn)
    }
    
    func findOrCreateContacts(userId: Int, contactId: Int, on conn: DatabaseConnectable) throws -> Future<Chat.ChatContacts> {
        
        let chat = findOrCreateChat(userId: userId, contactId: contactId, on: conn)
        
        return chat.map { chat in
            return try chat.getChatContacts(userId: userId)
        }
        
    }
    
    private func findOrCreateChat(userId: Int, contactId: Int, on conn: DatabaseConnectable) -> Future<Chat> {
        
        return Chat.findChat(userId: userId, contactId: contactId, conn: conn).flatMap({ chat -> Future<Chat> in
            
            if let chat = chat {
                
                return conn.eventLoop.newSucceededFuture(result: chat)
                
            } else {
                let newChat = Chat(firstId: contactId, secondId: userId)
                return newChat.save(on: conn)
            }
            
        })
    }
}
