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
        return Gift.find(giftId, on: req).unwrap(or: Abort(.giftNotFound)).map { gift in
            guard gift.isReviewed else { throw Abort(.unreviewedGift) }
            return gift
        }
    }
    
    func registeredGifts(_ req: Request) throws -> Future<[Gift]> {
        
        
        
        return try req.parameters.next(User.self).flatMap({ selectedUser in
            
            guard let selectedUserId = selectedUser.id else {
                throw Abort(.nilUserId)
            }
            
            let authUser = try req.requireAuthenticated(User.self)
            let isAdmin = authUser.isAdmin
            var isOwner = false
            if let authUserId = authUser.id,
                authUserId == selectedUserId {
                isOwner = true
            }
            
            
            return try req.content.decode(RequestInput.self).flatMap({ requestInput in
                
                let query = Gift.query(on: req, withSoftDeleted: (isAdmin || isOwner))
                .filter(\.userId == selectedUserId)
                
                if (isOwner && !isAdmin) {
                    query.filter(\.isDeleted == false)
                }
                
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: true, onlyReviewedGifts: !(isAdmin || isOwner))
            })
            
            
        })
        
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
        
        return Gift.find(id: giftId, withSoftDeleted: true, on: req).flatMap { gift in
            
            return try req.content.decode(Gift.Input.self).flatMap { input -> Future<Gift> in
                return try gift.update(input: input, authId: authId, on: req)
            }
        }
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            guard let userId = user.id , userId == gift.userId else {
                throw Abort(.unauthorizedGift)
            }
            gift.isDeleted = true
            return gift.save(on: req).flatMap({ gift in
                return gift.delete(on: req)
            })
            }.transform(to: .ok)
    }
    
}
