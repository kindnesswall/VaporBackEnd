//
//  AdminUnreviewedGiftsListController.swift
//  
//
//  Created by AmirHossein on 3/14/23.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class AdminUnreviewedGiftsListController: ListControllerProtocol {
    
    func index(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        try Gift.getGifts(giftQuery: getGiftQuery(req))
    }
    
    func paginatedIndex(_ req: Request) throws -> EventLoopFuture<Page<Gift.Output>> {
        try Gift.getPaginatedGifts(giftQuery: getGiftQuery(req))
    }
    
    func getGiftQuery(_ req: Request) throws -> GiftQuery {
        let requestInput = try req.query.decode(RequestInput.self)
        let query = Gift.query(on: req.db)
            .filter(\.$isReviewed == false)
        return GiftQuery(
            query: query,
            requestInput: requestInput,
            onlyReviewerAcceptedGifts: false)
    }
}
