//
//  UserRegisteredGiftsListController.swift
//  
//
//  Created by AmirHossein on 3/14/23.
//

import Vapor
import Fluent
import FluentPostgresDriver

class UserRegisteredGiftsListController: ListControllerProtocol {
    
    func index(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        let userId = try req.idParameter ?? req.requireAuthID()
        return try getGiftQuery(req, userId: userId).flatMap { giftQuery in
            Gift.getGifts(giftQuery: giftQuery)
        }
    }
    
    func paginatedIndex(_ req: Request) throws -> EventLoopFuture<Page<Gift.Output>> {
        let userId = try req.idParameter ?? req.requireAuthID()
        return try getGiftQuery(req, userId: userId).flatMap { giftQuery in
            Gift.getPaginatedGifts(giftQuery: giftQuery)
        }
    }
    
    func getGiftQuery(_ req: Request, userId: Int) throws -> EventLoopFuture<GiftQuery> {
        
        let auth = req.auth.get(User.self)
        let isAdmin = auth?.isAdmin ?? false
        let isOwner = auth?.id == userId
        let requestInput = try req.query.decode(RequestInput.self)
        
        return User.findOrFail(
            userId,
            withSoftDeleted: isAdmin,
            on: req.db).map { user in
                
                let query = Gift.query(on: req.db)
                    .filter(\.$user.$id == userId)
                
                if isAdmin || isOwner {
                    query.withDeleted()
                    query.filter(\.$isDeleted == false)
                }
                
                return GiftQuery(
                    query: query,
                    requestInput: requestInput,
                    onlyReviewerAcceptedGifts: !(isAdmin || isOwner))
            }
    }
}
