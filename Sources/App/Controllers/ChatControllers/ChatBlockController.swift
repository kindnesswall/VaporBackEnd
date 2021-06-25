//
//  ChatBlockController.swift
//  App
//
//  Created by Amir Hossein on 6/25/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

class ChatBlockController {
    
    func blockUser(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let authId = try req.auth.require(User.self).requireID()
        let chatId = try req.requireIDParameter()
        
        return DirectChat.set(
            block: true,
            authId: authId,
            chatId: chatId,
            on: req.db).flatMap { chatBlock in
                
                return ChatBlock.find(
                    chatBlock: chatBlock,
                    conn: req.db).flatMap { foundChatBlock in
                        
                        guard foundChatBlock == nil else {
                            return req.db.makeFailedFuture(
                                .userWasAlreadyBlocked)
                        }
                        return chatBlock.save(on: req.db)
                            .transform(to: .ok)
                }
        }
    }
    
    func unblockUser(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let authId = try req.auth.require(User.self).requireID()
        let chatId = try req.requireIDParameter()
        
        return DirectChat.set(
            block: false,
            authId: authId,
            chatId: chatId,
            on: req.db).flatMap { chatBlock in
                
                return ChatBlock.find(
                    chatBlock: chatBlock,
                    conn: req.db).flatMap { foundChatBlock in
                        
                        guard let foundChatBlock = foundChatBlock else {
                            return req.db.makeFailedFuture(
                                .userWasAlreadyUnblocked)
                        }
                        return foundChatBlock.delete(on: req.db)
                            .transform(to: .ok)
                }
        }
    }
    
}
