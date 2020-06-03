//
//  GiftRequestController.swift
//  App
//
//  Created by Amir Hossein on 3/13/19.
//

import Vapor


final class GiftRequestController: ChatInitializer {
    
    public func requestGift(_ req: Request) throws -> Future<ContactMessage> {
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
                
                //TODO: Code redundency reduction
                
                if giftRequestHasExisted {
                    return self.findOrCreateChat(userId: userId, contactId: giftOwnerId, on: req)
                } else {
                    return GiftRequest.create(requestUserId: userId, giftId: giftId, giftOwnerId: giftOwnerId, conn: req).flatMap({ _ in
                        return self.findOrCreateChat(userId: userId, contactId: giftOwnerId, on: req)
                    })
                }
            })
            
        }
    }
    
    public func requestStatus(_ req: Request) throws -> Future<GiftRequestStatus> {
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.getId()
        
        return try req.parameters.next(Gift.self).flatMap({ gift in
            let giftId = try gift.getId()
            return GiftRequest.hasExisted(requestUserId: userId, giftId: giftId, conn: req).flatMap({ isRequested in
                
                guard isRequested else {
                    let requestStatus = GiftRequestStatus(isRequested: false, chat: nil)
                    return req.eventLoop.newSucceededFuture(result: requestStatus)
                }
                
                let giftOwnerId = try gift.getUserId()
                return self.findChat(userId: userId, contactId: giftOwnerId, on: req).map({ chat in
                    guard let chat = chat else {
                        return GiftRequestStatus(isRequested: false, chat: nil)
                    }
                    
                    return GiftRequestStatus(isRequested: true, chat: chat)
                })
            })
        })
    }
    
}
