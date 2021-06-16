//
//  UserGiftsController.swift
//  App
//
//  Created by Amir Hossein on 6/30/20.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class UserGiftsController {
    
    func registeredGifts(_ req: Request) throws -> EventLoopFuture<[Gift]> {
        
        
        let auth = try req.auth.require(User.self)
        let isAdmin = auth.isAdmin
        let userId = req.idParameter
        let isOwner = (auth.id == userId)
        
        return User.findOrFail(userId, withSoftDeleted: isAdmin, on: req).flatMap { user in
            
            return try req.content.decode(RequestInput.self).flatMap { requestInput in
                
                let query = Gift.query(on: req, withSoftDeleted: (isAdmin || isOwner))
                .filter(\.userId == userId)
                
                if (isOwner && !isAdmin) {
                    query.filter(\.isDeleted == false)
                }
                
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: true, onlyReviewedGifts: !(isAdmin || isOwner))
            }
        }
        
    }
    
    func donatedGifts(_ req: Request) throws -> EventLoopFuture<[Gift]> {
        
        let auth = try req.auth.require(User.self)
        let isAdmin = auth.isAdmin
        let userId = req.idParameter
        
        return User.findOrFail(userId, withSoftDeleted: isAdmin, on: req).flatMap { user in
            
            return try req.content.decode(RequestInput.self).flatMap { requestInput in
                let query = try user.gifts.query(on: req)
                query.filter(\.donatedToUserId != nil)
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: false, onlyReviewedGifts: true)
            }
        }
    }
    
    func receivedGifts(_ req: Request) throws -> EventLoopFuture<[Gift]> {
        
        let auth = try req.auth.require(User.self)
        let isAdmin = auth.isAdmin
        let userId = req.idParameter
        
        return User.findOrFail(userId, withSoftDeleted: isAdmin, on: req).flatMap { user in
            return try req.content.decode(RequestInput.self).flatMap { requestInput in
                let query = try user.receivedGifts.query(on: req)
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: false, onlyReviewedGifts: true)
            }
        }
    }
    
}
