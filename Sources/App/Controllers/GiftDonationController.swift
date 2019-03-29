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
        return try req.content.decode(RequestInput.self).flatMap({ requestInput in
            let user = try req.requireAuthenticated(User.self)
            let query = try user.gifts.query(on: req)
            query.filter(\.donatedToUserId != nil)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: false)
        })
    }
    
    func receivedGifts(_ req: Request) throws -> Future<[Gift]> {
        return try req.content.decode(RequestInput.self).flatMap({ requestInput in
            let user = try req.requireAuthenticated(User.self)
            let query = try user.receivedGifts.query(on: req)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: false)
        })
    }
    
    func donate(_ req: Request) throws -> Future<Gift> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Donate.self).flatMap({ donate -> Future<Gift> in
            return Gift.find(donate.giftId, on: req).flatMap({ gift -> Future<Gift> in
                guard let gift = gift else {
                    throw Constants.errors.giftNotFound
                }
                guard let userId = user.id , userId == gift.userId else {
                    throw Constants.errors.unauthorizedGift
                }
//                guard gift.isReviewed == true else {
//                    throw Constants.errors.unreviewedGift
//                }
                return Chat.findChat(userId: userId, contactId: donate.donatedToUserId, conn: req).flatMap({ chat -> Future<Gift> in
                    guard chat != nil else {
                        throw Constants.errors.unauthorizedRequest
                    }
                    gift.donatedToUserId = donate.donatedToUserId
                    return gift.save(on: req)
                })
                
            })
        })
    }
}
