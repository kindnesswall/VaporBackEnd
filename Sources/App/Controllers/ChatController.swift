//
//  ChatController.swift
//  App
//
//  Created by Amir Hossein on 3/13/19.
//

import Vapor


final class ChatController{
    
    func getChatId(_ req: Request) throws -> Future<Chat> {
        
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.nilUserId
        }
        
        return try req.parameters.next(User.self).flatMap{ contactUser -> Future<Chat> in
            guard let contactId = contactUser.id else {
                throw Constants.errors.nilUserId
            }
            
            return Chat.findChat(userId: userId, contactId: contactId, conn: req).flatMap({ chat -> Future<Chat> in
                if let chat = chat {
                    let promise = req.eventLoop.newPromise(of: Chat.self)
                    promise.succeed(result: chat)
                    return promise.futureResult
                }
                let newChat = Chat(firstId: userId, secondId: contactId)
                return newChat.save(on: req)
                
            })
            
        }
        
    }
}
