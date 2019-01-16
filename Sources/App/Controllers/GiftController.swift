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
        return Gift.query(on: req).all()
    }
    
    /// Saves a decoded `Gift` to the database.
    func create(_ req: Request) throws -> Future<Gift> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Gift.self).flatMap { gift in
            gift.userId = user.id
            return gift.save(on: req)
        }
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            guard let userId = user.id , userId == gift.userId else {
                throw Constants.errors.unAuthorizedGift
            }
            return gift.delete(on: req)
            }.transform(to: .ok)
    }
    
    func filteredByCategory(_ req: Request) throws -> Future<[Gift]> {
        return try req.parameters.next(Category.self).flatMap { category in
            return try category.gifts.query(on: req).all()
        }
    }
    
}
