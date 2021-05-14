//
//  GiftDonationController.swift
//  App
//
//  Created by Amir Hossein on 3/14/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

class GiftDonationController {
    
    func giftsToDonate(_ req: Request) throws -> EventLoopFuture<[Gift]> {
        
        let user = try req.auth.require(User.self)
        guard let userId = user.id else {
            throw Abort(.nilUserId)
        }
        return try req.parameters.next(User.self).flatMap({ contactUser in
            guard let contactUserId = contactUser.id else {
                throw Abort(.nilUserId)
            }
            return try req.content.decode(RequestInput.self).flatMap({ requestInput in
                let userGifts = try user.gifts.query(on: req)
                let query=GiftRequest.getGiftsToDonate(userGifts: userGifts, userId: userId, requestUserId: contactUserId)
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: true, onlyReviewedGifts: true)
            })
        })
    }
    
    func donate(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let userId = try user.getId()
        
        return try req.content.decode(Donate.self).flatMap({ donate in
            
            guard userId != donate.donatedToUserId else {
                throw Abort(.giftCannotBeDonatedToTheOwner)
            }
            
            return GiftRequest.hasExisted(requestUserId: donate.donatedToUserId, giftId: donate.giftId, conn: req).flatMap({ giftRequestHasExisted in
                guard giftRequestHasExisted else {
                    throw Abort(.unrequestedGift)
                }
                
                return Gift.get(donate.giftId, on: req).flatMap({ gift in
                    
                    guard userId == gift.userId else {
                        throw Abort(.unauthorizedGift)
                    }
                    
                    guard gift.isReviewed == true else {
                        throw Abort(.unreviewedGift)
                    }
                    
                    guard gift.donatedToUserId == nil else {
                        throw Abort(.giftIsAlreadyDonated)
                    }
                    
                    gift.donatedToUserId = donate.donatedToUserId
                    return gift.save(on: req).transform(to: .ok)
                    
                })
                
            })
            
            
        })
    }
}
