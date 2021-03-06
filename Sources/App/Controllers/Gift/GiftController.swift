//
//  GiftController.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor
import FluentPostgreSQL

/// Controls basic CRUD operations on `Gift`s.
final class GiftController {
    
    /// Returns a list of all `Gift`s.
    func index(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.content.decode(RequestInput.self).flatMap { requestInput in
            let query = Gift.query(on: req)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: true, onlyReviewedGifts: true)
        }
        
    }
    
    func itemAt(_ req: Request) throws -> Future<Gift> {
        let giftId = try req.parameters.next(Int.self)
        return Gift.get(giftId, on: req).map { gift in
            guard gift.isReviewed else { throw Abort(.unreviewedGift) }
            return gift
        }
    }
    
    
    /// Saves a decoded `Gift` to the database.
    func create(_ req: Request) throws -> Future<Gift> {
        let authId = try req.requireAuthenticated(User.self).getId()
        return try req.content.decode(Gift.Input.self).flatMap { input in
            return try Gift.create(input: input, authId: authId, on: req)
        }
    }
    
    func update(_ req: Request) throws -> Future<Gift> {
        let authId = try req.requireAuthenticated(User.self).getId()
        let giftId = try req.parameters.next(Int.self)
        
        return Gift.get(giftId, withSoftDeleted: true, on: req).flatMap { gift in
            
            return try req.content.decode(Gift.Input.self).flatMap { input -> Future<Gift> in
                return try gift.update(input: input, authId: authId, on: req)
            }
        }
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let authId = try req.requireAuthenticated(User.self).getId()
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            guard gift.userId == authId else { throw Abort(.unauthorizedGift) }
            guard !gift.isDonated else { throw Abort(.donatedGiftUnaccepted) }
            gift.isDeleted = true
            return gift.save(on: req).flatMap({ gift in
                return gift.delete(on: req)
            })
            }.transform(to: .ok)
    }
    
}
