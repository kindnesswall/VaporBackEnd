//
//  GiftDonationController.swift
//  App
//
//  Created by Amir Hossein on 3/14/19.
//

import Vapor
import FluentPostgreSQL

class GiftDonationController {
    
    func donatedGifts(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.parameters.next(User.self).flatMap({ selectedUser in
            return try req.content.decode(RequestInput.self).flatMap({ requestInput in
                let query = try selectedUser.gifts.query(on: req)
                query.filter(\.donatedToUserId != nil)
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: false, onlyReviewedGifts: true)
            })
        })
    }
    
    func receivedGifts(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.parameters.next(User.self).flatMap({ selectedUser in
            return try req.content.decode(RequestInput.self).flatMap({ requestInput in
                let query = try selectedUser.receivedGifts.query(on: req)
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: false, onlyReviewedGifts: true)
            })
        })
    }
    
    func giftsToDonate(_ req: Request) throws -> Future<[Gift]> {
        
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.nilUserId
        }
        return try req.parameters.next(User.self).flatMap({ contactUser in
            guard let contactUserId = contactUser.id else {
                throw Constants.errors.nilUserId
            }
            return try req.content.decode(RequestInput.self).flatMap({ requestInput in
                let userGifts = try user.gifts.query(on: req)
                let query=GiftRequest.getGiftsToDonate(userGifts: userGifts, userId: userId, requestUserId: contactUserId)
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: true, onlyReviewedGifts: true)
            })
        })
    }
    
    func donate(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.getId()
        
        return try req.content.decode(Donate.self).flatMap({ donate in
            
            guard userId != donate.donatedToUserId else {
                throw Constants.errors.giftCannotBeDonatedToTheOwner
            }
            
            return GiftRequest.hasExisted(requestUserId: donate.donatedToUserId, giftId: donate.giftId, conn: req).flatMap({ giftRequestHasExisted in
                guard giftRequestHasExisted else {
                    throw Constants.errors.unrequestedGift
                }
                
                return Gift.find(donate.giftId, on: req).flatMap({ gift in
                    guard let gift = gift else {
                        throw Constants.errors.giftNotFound
                    }
                    
                    guard userId == gift.userId else {
                        throw Constants.errors.unauthorizedGift
                    }
                    
                    guard gift.isReviewed == true else {
                        throw Constants.errors.unreviewedGift
                    }
                    
                    guard gift.donatedToUserId == nil else {
                        throw Constants.errors.giftIsAlreadyDonated
                    }
                    
                    gift.donatedToUserId = donate.donatedToUserId
                    return gift.save(on: req).transform(to: .ok)
                    
                })
                
            })
            
            
        })
    }
}
