//
//  GiftRequestController.swift
//  App
//
//  Created by Amir Hossein on 3/13/19.
//

import Vapor


final class GiftRequestController{
    
    public func requestGift(_ req: Request) throws -> Future<Chat> {
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.nilUserId
        }
        return try req.parameters.next(Gift.self).flatMap { gift in
            guard let giftId = gift.id else {
                throw Constants.errors.nilGiftId
            }
            guard let giftOwnerId = gift.userId else {
                throw Constants.errors.nilGiftUserId
            }
            
            guard userId != giftOwnerId else {
                throw Constants.errors.giftCannotBeDonatedToTheOwner
            }
            
            guard gift.isReviewed == true else {
                throw Constants.errors.unreviewedGift
            }
            
            guard gift.donatedToUserId == nil else {
                throw Constants.errors.giftIsAlreadyDonated
            }
            
            return GiftRequest.hasExisted(requestUserId: userId, giftId: giftId, conn: req).flatMap({ giftRequestHasExisted in
                
                if giftRequestHasExisted {
                    return try self.getChatId(userId: userId, contactId: giftOwnerId, conn: req)
                } else {
                    return GiftRequest.create(requestUserId: userId, giftId: giftId, giftOwnerId: giftOwnerId, conn: req).flatMap({ _ in
                        return try self.getChatId(userId: userId, contactId: giftOwnerId, conn: req)
                    })
                }
            })
            
        }
    }
    
    
    
    private func getChatId(userId:Int,contactId:Int,conn:DatabaseConnectable) throws -> Future<Chat> {
        
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
