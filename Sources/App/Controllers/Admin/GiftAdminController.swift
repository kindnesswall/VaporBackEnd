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
        
        return Gift.getParameter(on: req).flatMap { (gift) -> EventLoopFuture<Void> in
            
            return try req.content.decode(Inputs.RejectReason.self).flatMap({ input in 
                
                gift.isRejected = true
                gift.rejectReason = input.rejectReason
                gift.isReviewed = true
                
                return gift.save(on: req).flatMap({ gift in
                    return gift.delete(on: req)
                })
                
            })
            }.transform(to: .ok)
    }
    
    func acceptGift(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        return Gift.getParameter(on: req).flatMap { (gift) -> EventLoopFuture<Gift> in
            
            gift.isReviewed = true
            gift.isRejected = false
            gift.rejectReason = nil
            
            return gift.save(on: req)
            }.transform(to: .ok)
    }
    
    func unreviewedGifts(_ req: Request) throws -> EventLoopFuture<[Gift]> {
        
        return try req.content.decode(RequestInput.self).flatMap { requestInput in
            let query = Gift.query(on: req).filter(\.isReviewed == false)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: false,onlyReviewedGifts: false)
        }
        
    }
    
}
