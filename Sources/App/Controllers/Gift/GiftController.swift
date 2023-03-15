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
        let authId = try req.getAuthId()
        let input = try req.content.decode(Gift.Input.self)
        
        return Gift.findOrFail(req.idParameter,
                               withSoftDeleted: true,
                               on: req.db)
        .flatMap { gift in
            return gift.update(input: input, authId: authId, on: req)
                .outputObject
        }
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authId = try req.getAuthId()
        return Gift.findOrFail(req.idParameter,
                               withSoftDeleted: true,
                               on: req.db)
        .flatMap { gift in
            return gift.delete(authId: authId, on: req.db)
                .transform(to: .ok)
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
