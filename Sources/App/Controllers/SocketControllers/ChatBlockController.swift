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

        let contactChatBlock = try getContactChatBlock(req)
        return contactChatBlock.flatMap { contactChatBlock in

            return ChatBlock.find(chatBlock: contactChatBlock, conn: req).flatMap({ foundChatBlock in

                guard foundChatBlock == nil else {
                    throw Constants.errors.userWasAlreadyBlocked
                }
                return contactChatBlock.save(on: req).map({ _ in
                    return HTTPStatus.ok
                })

            })
        }

    }
    
    func unblockUser(_ req: Request) throws -> Future<HTTPStatus> {
        
        let contactChatBlock = try getContactChatBlock(req)
        return contactChatBlock.flatMap { contactChatBlock in
            
            return ChatBlock.find(chatBlock: contactChatBlock, conn: req).flatMap({ foundChatBlock in
                
                guard let foundChatBlock = foundChatBlock else {
                    throw Constants.errors.userWasAlreadyUnblocked
                }
                return foundChatBlock.delete(on: req).map({ _ in
                    return HTTPStatus.ok
                })
            })
                
        }
        
    }
    
    
    private func getContactChatBlock(_ req: Request) throws -> Future<ChatBlock>{
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.nilUserId
        }
        return try req.parameters.next(Chat.self).flatMap({ chat in
            
            guard let chatId = chat.id else {
                throw Constants.errors.nilChatId
            }
            let chatContacts = try Chat.getChatContacts(userId: userId, chat: chat, conn: req, withBlocked: true)
            
            return chatContacts.map({ chatContacts in
                return ChatBlock(chatId: chatId, blockedUserId: chatContacts.contactId)
            })
            
        })
    }
}
