//
//  ChatBlockController.swift
//  App
//
//  Created by Amir Hossein on 6/25/19.
//

import Vapor
import FluentPostgreSQL

class ChatBlockController {
    
    func blockUser(_ req: Request) throws -> Future<HTTPStatus> {
        
        let userId = try getUserId(req)
        return try req.parameters.next(Chat.self).flatMap({ chat in
            
            // Being sure that the user is associated with chat
            let chatContacts = try chat.getChatContacts(userId: userId)
            
            return try chat.setContactBlock(userId: userId, block: true, conn: req).flatMap({ chat in
                
                let chatBlock = try self.getChatBlock(contacts: chatContacts)
                return ChatBlock.find(chatBlock: chatBlock, conn: req).flatMap({ foundChatBlock in
                    
                    guard foundChatBlock == nil else {
                        throw Constants.errors.userWasAlreadyBlocked
                    }
                    return chatBlock.save(on: req).map({ _ in
                        return HTTPStatus.ok
                    })
                })
            })
        })
    }
    
    func unblockUser(_ req: Request) throws -> Future<HTTPStatus> {
        
        let userId = try getUserId(req)
        return try req.parameters.next(Chat.self).flatMap({ chat in
            
            // Being sure that the user is associated with chat
            let chatContacts = try chat.getChatContacts(userId: userId)
            
            return try chat.setContactBlock(userId: userId, block: false, conn: req).flatMap({ chat in
                
                let chatBlock = try self.getChatBlock(contacts: chatContacts)
                return ChatBlock.find(chatBlock: chatBlock, conn: req).flatMap({ foundChatBlock in
                    
                    guard let foundChatBlock = foundChatBlock else {
                        throw Constants.errors.userWasAlreadyUnblocked
                    }
                    return foundChatBlock.delete(on: req).map({ _ in
                        return HTTPStatus.ok
                    })
                })
            })
        })
    }
    
    private func getUserId(_ req: Request) throws -> Int {
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.getId()
        return userId
    }
    
    private func getChatBlock(contacts: Chat.ChatContacts) throws -> ChatBlock {
        
        let chatBlock = ChatBlock(chatId: contacts.chatId, blockedUserId: contacts.contactId, byUserId: contacts.userId)
        return chatBlock
    }
    
}
