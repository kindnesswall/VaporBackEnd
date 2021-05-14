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
    
    func blockUser(_ req: Request) throws -> Future<HTTPStatus> {
        
        let userId = try getUserId(req)
        let chatId = try req.parameters.next(Int.self)
        
        return DirectChat.set(block: true, authId: userId, chatId: chatId, on: req).flatMap { chatBlock in
            
            return ChatBlock.find(chatBlock: chatBlock, conn: req).flatMap({ foundChatBlock in
                
                guard foundChatBlock == nil else {
                    throw Abort(.userWasAlreadyBlocked)
                }
                return chatBlock.save(on: req).map({ _ in
                    return HTTPStatus.ok
                })
            })
        }
    }
    
    func unblockUser(_ req: Request) throws -> Future<HTTPStatus> {
        
        let userId = try getUserId(req)
        let chatId = try req.parameters.next(Int.self)
        
        return DirectChat.set(block: false, authId: userId, chatId: chatId, on: req).flatMap { chatBlock in
            
            return ChatBlock.find(chatBlock: chatBlock, conn: req).flatMap({ foundChatBlock in
                
                guard let foundChatBlock = foundChatBlock else {
                    throw Abort(.userWasAlreadyUnblocked)
                }
                return foundChatBlock.delete(on: req).map({ _ in
                    return HTTPStatus.ok
                })
            })
        }
    }
    
    private func getUserId(_ req: Request) throws -> Int {
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.getId()
        return userId
    }
    
}
