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
    func index(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        
        let requestInput = try req.content.decode(RequestInput.self)
        let query = Gift.query(on: req.db)
        return Gift.getGiftsWithRequestFilter(
            query: query,
            requestInput: requestInput,
            onlyReviewerAcceptedGifts: true)
            .outputArray
    }
    
    func itemAt(_ req: Request) throws -> EventLoopFuture<Gift.Output> {
        return Gift.getParameter(on: req).flatMapThrowing { gift in
            guard gift.isAcceptedByReviewer else { throw Abort(.unreviewedGift) }
            return gift
        }
        .outputObject
    }
    
    
    /// Saves a decoded `Gift` to the database.
    func create(_ req: Request) throws -> EventLoopFuture<Gift.Output> {
        let authId = try req.auth.require(User.self).getId()
        let input = try req.content.decode(Gift.Input.self)
        return Gift.create(input: input, authId: authId, on: req)
            .outputObject
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Gift.Output> {
        let authId = try req.auth.require(User.self).getId()
        let giftId = req.idParameter
        let input = try req.content.decode(Gift.Input.self)
        
        return Gift.findOrFail(giftId, withSoftDeleted: true, on: req.db).flatMap { gift in
            do {
                return try gift.update(input: input, authId: authId, on: req)
            } catch(let error) {
                return req.db.makeFailedFuture(error)
            }
        }
        .outputObject
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authId = try req.auth.require(User.self).getId()
        
        return Gift.getParameter(on: req).flatMap { gift in
            do {
                return try gift.delete(authId: authId, on: req.db)
            } catch(let error) {
                return req.db.makeFailedFuture(error)
            }
        }
    }
    
    func isDelivered(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let db = req.db
        let authId = try req.auth.require(User.self)
            .getId()
        let giftId = req.idParameter
        
        return Gift.findOrFail(giftId, on: db)
            .flatMap { gift in
                guard gift.$donatedToUser.id == authId
                else {
                    return db
                        .makeFailedFuture(.notAcceptable)
                }
                gift.isDelivered = true
                return gift.save(on: db)
                    .transform(to: .ok)
            }
    }
    
}
