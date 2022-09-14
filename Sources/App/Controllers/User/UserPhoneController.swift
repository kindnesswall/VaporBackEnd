//
//  UserPhoneController.swift
//  App
//
//  Created by Amir Hossein on 5/1/21.
//

import Vapor
import FluentKit

final class UserPhoneController {
    
    func getPhoneNumberOfAGift(_ req: Request) throws -> EventLoopFuture<Outputs.UserPhoneNumber> {
        
        let auth = try req.auth.require(User.self)
        let authId = try auth.getId()
        let giftId = try req.requireIDParameter()
        
        return try getUserIfPhoneNumberIsAccessible(giftId: giftId, auth: auth, on: req.db)
            .flatMap { user in
                guard let userId = user.id else {
                    return req.db.makeFailedFuture(.nilUserId)
                }
                
                let log = PhoneNumberSeenLog(
                    fromUserId: authId,
                    seenUserId: userId,
                    seenPhoneNumber: user.phoneNumber)
                
                let output = Outputs.UserPhoneNumber(phoneNumber: user.phoneNumber)
                
                return log.create(on: req.db)
                    .transform(to: output)
            }
    }
    
    private func getUserIfPhoneNumberIsAccessible(
        giftId: Int,
        auth: User,
        on db: Database) throws -> EventLoopFuture<User>
    {
        
        try getUserIdIfPhoneNumberIsAccessible(
            giftId: giftId,
            auth: auth,
            on: db).flatMap { userId in
                User.findOrFail(
                    userId,
                    on: db)
            }
    }
    
    private func getUserIdIfPhoneNumberIsAccessible(
        giftId: Int,
        auth: User,
        on db: Database) throws -> EventLoopFuture<Int>
    {
        let authId = try auth.getId()
        let isAdmin = auth.isAdmin
        let isCharity = auth.isCharity
        guard isAdmin || isCharity else {
            throw Abort(.unauthorizedRequest)
        }
        if isAdmin {
            return Gift
                .findOrFail(giftId, on: db)
                .map { $0.$user.id }
                .unwrap(or: Abort(.nilGiftUserId))
        } else {
            return GiftRequest.findValidRequest(
                requestUserId: authId,
                giftId: giftId,
                db: db)
            .unwrap(or: Abort(.unauthorizedRequest))
            .map { $0.giftOwnerId }
        }
    }
}
