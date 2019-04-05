//
//  GiftAdminController.swift
//  App
//
//  Created by Amir Hossein on 2/4/19.
//

import Vapor
import FluentPostgreSQL

final class GiftAdminController {
    
    func rejectGift(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            gift.isReviewed = false
            return gift.save(on: req).flatMap({ gift in
                return gift.delete(on: req)
            })
            }.transform(to: .ok)
    }
    
    func acceptGift(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Gift> in
            gift.isReviewed = true
            return gift.save(on: req)
            }.transform(to: .ok)
    }
    
    func unreviewedGifts(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.content.decode(RequestInput.self).flatMap { requestInput in
            let query = Gift.query(on: req).filter(\.isReviewed == false)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: false)
        }
        
    }
    
}
