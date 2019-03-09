//
//  GiftController.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor

/// Controls basic CRUD operations on `Gift`s.
final class GiftController {
    
    /// Returns a list of all `Gift`s.
    func index(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.content.decode(RequestInput.self).flatMap { requestInput in
            let query = Gift.query(on: req)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput)
        }
        
    }
    
    func ownerGifts(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.content.decode(RequestInput.self).flatMap({ requestInput in
            let user = try req.requireAuthenticated(User.self)
            let query = try user.gifts.query(on: req)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput)
        })
        
    }
    
    /// Saves a decoded `Gift` to the database.
    func create(_ req: Request) throws -> Future<Gift> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Gift.Input.self).flatMap { inputGift in
            let gift = Gift(userId: user.id, gift: inputGift)
            return self.saveGift(gift: gift, req: req)
        }
    }
    
    func update(_ req: Request) throws -> Future<Gift> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Gift> in
            guard let userId = user.id , userId == gift.userId else {
                throw Constants.errors.unauthorizedGift
            }
            
            return try req.content.decode(Gift.Input.self).flatMap { inputGift -> Future<Gift> in
                gift.update(gift: inputGift)
                return self.saveGift(gift: gift, req: req)
            }
            
        }
        
    }
    
    private func saveGift(gift:Gift,req: Request)->Future<Gift>{
        return gift.category.get(on: req).flatMap({ (category) -> Future<Gift> in
            gift.categoryTitle = category.title
            return gift.save(on: req)
        })
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            guard let userId = user.id , userId == gift.userId else {
                throw Constants.errors.unauthorizedGift
            }
            return gift.delete(on: req)
            }.transform(to: .ok)
    }
    
}
