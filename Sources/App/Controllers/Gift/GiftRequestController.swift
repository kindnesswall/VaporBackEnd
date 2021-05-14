//
//  GiftRequestController.swift
//  App
//
//  Created by Amir Hossein on 3/13/19.
//

import Vapor


final class GiftRequestController: ChatInitializer {
    
    public func requestGift(_ req: Request) throws -> EventLoopFuture<ContactMessage> {
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Abort(.nilUserId)
        }
        return try req.parameters.next(Gift.self).flatMap { gift in
            guard let giftId = gift.id else {
                throw Abort(.nilGiftId)
            }
            guard let giftOwnerId = gift.userId else {
                throw Abort(.nilGiftUserId)
            }
            
            guard userId != giftOwnerId else {
                throw Abort(.giftCannotBeDonatedToTheOwner)
            }
            
            guard gift.isReviewed == true else {
                throw Abort(.unreviewedGift)
            }
            
            guard gift.donatedToUserId == nil else {
                throw Abort(.giftIsAlreadyDonated)
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
    
    public func requestStatus(_ req: Request) throws -> EventLoopFuture<GiftRequestStatus> {
        let authId = try req.requireAuthenticated(User.self).getId()
        let giftId = try req.parameters.next(Int.self)
        
        return Gift.get(giftId, on: req).flatMap { gift in
            
            let ownerId = try gift.getUserId()
            
            if authId == ownerId {
                if let receiverId = gift.donatedToUserId {
                    
                    return self.findChat(userId: authId, contactId: receiverId, on: req).map { chat in
                        
                        guard let chat = chat else {
                            //Note: Throwing an error
                            throw Abort(.chatNotFound)
                        }
                        
                        return GiftRequestStatus(.donated(chat: chat))
                    }
                    
                } else {
                    return req.future(GiftRequestStatus(.notDonated))
                }
                
            }
            
            return GiftRequest.hasExisted(requestUserId: authId, giftId: giftId, conn: req).flatMap { isRequested in
                
                if isRequested {
                    
                    return self.findChat(userId: authId, contactId: ownerId, on: req).map { chat in
                        
                        guard let chat = chat else {
                            //Note: Instead of throwing an error, we ask user to request again.
                            return GiftRequestStatus(.notRequested)
                        }
                        
                        return GiftRequestStatus(.requested(chat: chat))
                    }
                    
                } else {
                    return req.future(GiftRequestStatus(.notRequested))
                }
                
            }
        }
    }
    
}
