//
//  ChatInitializer.swift
//  App
//
//  Created by Amir Hossein on 5/10/20.
//

import Vapor

class ChatInitializer {
    
    
    func findOrCreateChat(user: User, contact: User, on req: Request) throws -> EventLoopFuture<ContactMessage> {
        let userId = try user.getId()
        let contactId = try contact.getId()
        return findOrCreateChat(userId: userId, contactId: contactId, on: req)
    }
    
    func findOrCreateChat(userId: Int, contactId: Int, on req: Request) -> EventLoopFuture<ContactMessage> {
        return DirectChat.findOrCreate(userId: userId, contactId: contactId, on: req).flatMap { item in
            return User.find(item.contactId, on: req).unwrap(or: Abort(.profileNotFound)).map { contact in
                item.contactProfile = try contact.userProfile(req: req)
                return item
            }
        }
    }
    
    func findChat(userId: Int, contactId: Int, on conn: DatabaseConnectable) -> EventLoopFuture<ContactMessage?> {
        return DirectChat.find(userId: userId, contactId: contactId, on: conn)
    }
    
}
