//
//  UserRequestedGiftsListController.swift
//  
//
//  Created by AmirHossein on 3/14/23.
//

import Vapor
import Fluent

class UserRequestedGiftsListController: ListControllerProtocol {
    
    func index(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        let userId = try req.idParameter ?? req.requireAuthID()
        return try getQuery(req, userId: userId)
            .all()
            .outputArray
    }
    
    func paginatedIndex(_ req: Request) throws -> EventLoopFuture<Page<Gift.Output>> {
        
        let userId = try req.idParameter ?? req.requireAuthID()
        let requestInput = try req.query.decode(PaginationRequestInput.self)
        let page = requestInput.page ?? 1
        let count = requestInput.getCount()
        
        return try getQuery(req, userId: userId)
            .paginate(PageRequest(page: page, per: count))
            .outputPage
    }
    
    func getQuery(_ req: Request, userId: Int) throws -> QueryBuilder<Gift> {
        return GiftRequest
            .getUserRequestedGiftsQuery(requestUserId: userId, db: req.db)
    }
    
}
