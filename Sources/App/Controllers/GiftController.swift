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
        return try req.content.decode(Gift.self).flatMap { gift in
            return gift.save(on: req)
        }
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Gift.self).flatMap { gift in
            return gift.delete(on: req)
            }.transform(to: .ok)
    }
    
}
