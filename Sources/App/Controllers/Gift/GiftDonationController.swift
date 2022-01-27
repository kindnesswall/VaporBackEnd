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
    
    func giftsToDonate(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        
        let auth = try req.auth.require(User.self)
        let authId = try auth.getId()
        let requestInput = try req.content.decode(RequestInput.self)
        
        return User.getParameter(on: req).flatMap { contactUser in
            guard let contactUserId = contactUser.id else {
                return req.db.makeFailedFuture(.nilUserId)
            }
            let userGifts = auth.$gifts.query(on: req.db)
            let query = GiftRequest.getGiftsToDonate(
                userGifts: userGifts,
                userId: authId,
                requestUserId: contactUserId)
            return Gift.getGiftsWithRequestFilter(
                query: query,
                requestInput: requestInput,
                onlyUndonatedGifts: true,
                onlyReviewedGifts: true)
        }
        .outputArray
    }
    
    func donate(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let auth = try req.auth.require(User.self)
        let authId = try auth.getId()
        let donate = try req.content.decode(Donate.self)
        
        guard authId != donate.donatedToUserId else {
            throw Abort(.giftCannotBeDonatedToTheOwner)
        }
        
        return GiftRequest.hasExisted(
            requestUserId: donate.donatedToUserId,
            giftId: donate.giftId,
            conn: req.db).flatMap { giftRequestHasExisted in
            guard giftRequestHasExisted else {
                return req.db.makeFailedFuture(.unrequestedGift)
            }
            return Gift.findOrFail(donate.giftId, on: req.db).flatMap { gift in
                
                do {
                    return try gift.donate(
                    to: donate.donatedToUserId,
                    authId: authId,
                    on: req.db)
                } catch(let error) {
                    return req.db.makeFailedFuture(error)
                }
            }
        }
    }
}
