//
//  GiftsListController.swift
//  
//
//  Created by AmirHossein on 3/10/23.
//

import Vapor
import Fluent

class GiftsListController: ListControllerProtocol {
    
    /// Returns a list of all `Gift`s.
    func index(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        return try Gift
            .getGifts(giftQuery: getGiftQuery(req))
    }
    
    func paginatedIndex(_ req: Request) throws -> EventLoopFuture<Page<Gift.Output>> {
        return try Gift
            .getPaginatedGifts(giftQuery: getGiftQuery(req))
    }
    
    func getGiftQuery(_ req: Request) throws -> GiftQuery {
        let requestInput = try req.query.decode(RequestInput.self)
        let query = Gift.query(on: req.db)
        return GiftQuery(
            query: query,
            requestInput: requestInput,
            onlyReviewerAcceptedGifts: true)
    }
    
}
