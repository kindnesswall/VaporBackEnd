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
    
    func registeredGifts(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        
        let auth = try req.auth.require(User.self)
        let isAdmin = auth.isAdmin
        let userId = try req.requireIDParameter()
        let isOwner = auth.id == userId
        let requestInput = try req.content.decode(RequestInput.self)
        
        return User.findOrFail(
            userId,
            withSoftDeleted: isAdmin,
            on: req.db).flatMap { user in
                
                let query = Gift.query(on: req.db)
                    .filter(\.$user.$id == userId)
                
                if isAdmin || isOwner {
                    query.withDeleted()
                }
                
                if isOwner && !isAdmin {
                    query.filter(\.$isDeleted == false)
                }
                
                return Gift.getGiftsWithRequestFilter(
                    query: query,
                    requestInput: requestInput,
                    onlyReviewedGifts: !(isAdmin || isOwner))
            }
            .outputArray
        
    }
    
    func donatedGifts(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        
        let auth = try req.auth.require(User.self)
        let isAdmin = auth.isAdmin
        let userId = try req.requireIDParameter()
        let requestInput = try req.content.decode(RequestInput.self)
        
        return User.findOrFail(
            userId,
            withSoftDeleted: isAdmin,
            on: req.db).flatMap { user in
                
                let query = user.$gifts.query(on: req.db)
                query.filter(\.$donatedToUser.$id != nil)
                return Gift.getGiftsWithRequestFilter(
                    query: query,
                    requestInput: requestInput,
                    onlyReviewedGifts: true)
                
            }
            .outputArray
    }
    
    func receivedGifts(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        
        let auth = try req.auth.require(User.self)
        let isAdmin = auth.isAdmin
        let userId = try req.requireIDParameter()
        let requestInput = try req.content.decode(RequestInput.self)
        
        return User.findOrFail(
            userId,
            withSoftDeleted: isAdmin,
            on: req.db).flatMap { user in
                
                let query = user.$receivedGifts.query(on: req.db)
                return Gift.getGiftsWithRequestFilter(
                    query: query,
                    requestInput: requestInput,
                    onlyReviewedGifts: true)
                
            }
            .outputArray
    }
    
    func requestedGifts(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        let userId = try req.requireIDParameter()
        return GiftRequest
            .getUserRequestedGifts(requestUserId: userId, db: req.db)
            .outputArray
    }
    
}
