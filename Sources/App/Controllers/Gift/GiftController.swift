//
//  GiftController.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

/// Controls basic CRUD operations on `Gift`s.
final class GiftController {
    
    /// Returns a list of all `Gift`s.
    func index(_ req: Request) throws -> EventLoopFuture<[Gift]> {
        
        return try req.content.decode(RequestInput.self).flatMap { requestInput in
            let query = Gift.query(on: req)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: true, onlyReviewedGifts: true)
        }
        
    }
    
    func itemAt(_ req: Request) throws -> EventLoopFuture<Gift> {
        return Gift.getParameter(on: req).flatMapThrowing { gift in
            guard gift.isReviewed else { throw Abort(.unreviewedGift) }
            return gift
        }
    }
    
    
    /// Saves a decoded `Gift` to the database.
    func create(_ req: Request) throws -> EventLoopFuture<Gift> {
        let authId = try req.auth.require(User.self).getId()
        return try req.content.decode(Gift.Input.self).flatMap { input in
            return try Gift.create(input: input, authId: authId, on: req)
        }
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Gift> {
        let authId = try req.auth.require(User.self).getId()
        let giftId = req.idParameter
        let input = try req.content.decode(Gift.Input.self)
        
        return Gift.findOrFail(giftId, withSoftDeleted: true, on: req.db).flatMap { gift in
            return try gift.update(input: input, authId: authId, on: req)
        }
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authId = try req.auth.require(User.self).getId()
        
        return Gift.getParameter(on: req).flatMap { (gift) -> EventLoopFuture<Void> in
            guard gift.userId == authId else { throw Abort(.unauthorizedGift) }
            guard !gift.isDonated else { throw Abort(.donatedGiftUnaccepted) }
            gift.isDeleted = true
            return gift.save(on: req).flatMap({ gift in
                return gift.delete(on: req)
            })
            }.transform(to: .ok)
    }
    
}
