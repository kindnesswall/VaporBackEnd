//
//  ChatInitializer.swift
//  App
//
//  Created by Amir Hossein on 5/10/20.
//

import Vapor
import Fluent

class ChatInitializer {
    
    func findOrCreateChat(user: User, contact: User, on req: Request) -> EventLoopFuture<ContactMessage> {
        guard
            let userId = user.id,
            let contactId = contact.id
            else {
                return req.db.makeFailedFuture(
                    .nilUserId)
        }
        return findOrCreateChat(userId: userId, contactId: contactId, on: req)
    }
    
    func findOrCreateChat(userId: Int, contactId: Int, on req: Request) -> EventLoopFuture<ContactMessage> {
        return DirectChat.findOrCreate(
            userId: userId,
            contactId: contactId,
            on: req.db).flatMap { item in
            return User.findOrFail(
                item.contactId,
                on: req.db,
                error: .profileNotFound).flatMapThrowing { contact in
                item.contactProfile = try contact.userProfile(req: req)
                return item
            }
        }
    }
    
    func findChat(userId: Int, contactId: Int, on conn: Database) -> EventLoopFuture<ContactMessage?> {
        return DirectChat.find(userId: userId, contactId: contactId, on: conn)
    }
    
}
