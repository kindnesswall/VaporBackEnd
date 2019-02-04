//
//  GiftAdminController.swift
//  App
//
//  Created by Amir Hossein on 2/4/19.
//

import Vapor


final class GiftAdminController {
    
    func rejectGift(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            gift.isReviewed = false
            gift.save(on: req).catch(AppErrorCatch.printError)
            
            return gift.delete(on: req)
            }.transform(to: .ok)
    }
    
    func acceptGift(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Gift> in
            gift.isReviewed = true
            return gift.save(on: req)
            }.transform(to: .ok)
    }
    
}
