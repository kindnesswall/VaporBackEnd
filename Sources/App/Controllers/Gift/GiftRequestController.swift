//
//  GiftRequestController.swift
//  App
//
//  Created by Amir Hossein on 3/13/19.
//

import Vapor
import Fluent

final class GiftRequestController: ChatInitializer {
    
    public func requestGift(_ req: Request) throws -> EventLoopFuture<ContactMessage> {
        let db = req.db
        let auth = try req.auth.require(User.self)
        let authId = try auth.getId()
        let giftId = try req.requireIDParameter()
        
        return Gift.findOrFail(giftId, on: db).flatMap { gift in
            
            guard let giftOwnerId = gift.$user.id else {
                return db.makeFailedFuture(.nilGiftUserId)
            }
            
            guard authId != giftOwnerId else {
                return db.makeFailedFuture(.giftCannotBeDonatedToTheOwner)
            }
            
            guard gift.isReviewed == true else {
                return db.makeFailedFuture(.unreviewedGift)
            }
            
            guard gift.$donatedToUser.id == nil else {
                return db.makeFailedFuture(.giftIsAlreadyDonated)
            }
            
            return GiftRequest.hasExisted(
                requestUserId: authId,
                giftId: giftId,
                conn: db).flatMap { giftRequestHasExisted in
                    
                    //TODO: Code redundency reduction
                    
                    if giftRequestHasExisted {
                        return self.findOrCreateChat(
                            userId: authId,
                            contactId: giftOwnerId,
                            on: req)
                    }
                    else {
                        return GiftRequest.create(
                            requestUserId: authId,
                            giftId: giftId,
                            giftOwnerId: giftOwnerId,
                            conn: db).flatMap { _ in
                                return self.findOrCreateChat(
                                    userId: authId,
                                    contactId: giftOwnerId,
                                    on: req)
                        }
                    }
            }
            
        }
    }
    
    public func requestStatus(_ req: Request) throws -> EventLoopFuture<GiftRequestStatus> {
        let db = req.db
        let authId = try req.auth.require(User.self).getId()
        let giftId = try req.requireIDParameter()
        
        return Gift.findOrFail(giftId, on: db).flatMap { gift in
            
            guard let giftOwnerId = gift.$user.id else {
                return db.makeFailedFuture(.nilGiftUserId)
            }
            
            if authId == giftOwnerId {
                if let receiverId = gift.$donatedToUser.id {
                    
                    return self.findChat(
                        userId: authId,
                        contactId: receiverId,
                        on: db).flatMapThrowing { chat in
                        
                        guard let chat = chat else {
                            //Note: Throwing an error
                            throw Abort(.chatNotFound)
                        }
                        
                        return GiftRequestStatus(.donated(chat: chat))
                    }
                    
                } else {
                    return db.makeSucceededFuture(
                        GiftRequestStatus(.notDonated))
                }
                
            }
            
            return GiftRequest.hasExisted(
                requestUserId: authId,
                giftId: giftId,
                conn: db).flatMap { isRequested in
                
                if isRequested {
                    
                    return self.findChat(
                        userId: authId,
                        contactId: giftOwnerId,
                        on: db).map { chat in
                        
                        guard let chat = chat else {
                            //Note: Instead of throwing an error, we ask user to request again.
                            return GiftRequestStatus(.notRequested)
                        }
                        
                        return GiftRequestStatus(.requested(chat: chat))
                    }
                    
                } else {
                    return db.makeSucceededFuture(
                        GiftRequestStatus(.notRequested))
                }
                
            }
        }
    }
    
}
