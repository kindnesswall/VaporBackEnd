//
//  GiftAdminController.swift
//  App
//
//  Created by Amir Hossein on 2/4/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class GiftAdminController {
    
    func rejectGift(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let input = try req.content.decode(Inputs.RejectReason.self)
        return Gift.getParameter(on: req).flatMap { gift in
            gift.isRejected = true
            gift.rejectReason = input.rejectReason
            gift.isReviewed = true
            return gift.save(on: req.db).flatMap { _ in
                return gift.delete(on: req.db)
                    .transform(to: .ok)
            }
        }
    }
    
    func acceptGift(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        return Gift.getParameter(on: req).flatMap { gift in
            gift.isReviewed = true
            gift.isRejected = false
            gift.rejectReason = nil
            return gift.save(on: req.db)
                .transform(to: .ok)
        }
    }
    
    func unreviewedGifts(_ req: Request) throws -> EventLoopFuture<[Gift.Output]> {
        
        let requestInput = try req.content.decode(RequestInput.self)
        let query = Gift.query(on: req.db)
            .filter(\.$isReviewed == false)
        return Gift.getGiftsWithRequestFilter(
            query: query,
            requestInput: requestInput,
            onlyUndonatedGifts: false,
            onlyReviewedGifts: false)
            .outputArray
    }
    
}
