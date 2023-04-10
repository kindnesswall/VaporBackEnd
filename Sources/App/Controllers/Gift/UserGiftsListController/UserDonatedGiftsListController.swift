//
//  UserDonatedGiftsListController.swift
//  
//
//  Created by AmirHossein on 3/14/23.
//

import Vapor
import Fluent
import FluentSQL

class UserDonatedGiftsListController: ListControllerProtocol {
    
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
        let requestInput = try req.query.decode(RequestInput.self)
        
        return User.findOrFail(
            userId,
            withSoftDeleted: isAdmin,
            on: req.db).map { user in
                
                let query = user.$gifts.query(on: req.db)
                query.filter(\.$donatedToUser.$id != nil)
                return GiftQuery(
                    query: query,
                    requestInput: requestInput,
                    onlyReviewerAcceptedGifts: true)
                
            }
    }
    
}
