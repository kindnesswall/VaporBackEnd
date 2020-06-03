//
//  ChatInitializer.swift
//  App
//
//  Created by Amir Hossein on 5/10/20.
//

import Vapor

class ChatInitializer {
    
    
    func findOrCreateChat(user: User, contact: User, on conn: DatabaseConnectable) throws -> Future<ContactMessage> {
        let userId = try user.getId()
        let contactId = try contact.getId()
        return findOrCreateChat(userId: userId, contactId: contactId, on: conn)
    }
    
    func findOrCreateChat(userId: Int, contactId: Int, on conn: DatabaseConnectable) -> Future<ContactMessage> {
        return DirectChat.findOrCreate(userId: userId, contactId: contactId, on: conn)
    }
    
    func findChat(userId: Int, contactId: Int, on conn: DatabaseConnectable) -> Future<ContactMessage?> {
        return DirectChat.find(userId: userId, contactId: contactId, on: conn)
    }
    
}
