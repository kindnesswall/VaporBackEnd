//
//  RatingController.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor

final class RatingController {
    
    func get(_ req: Request) throws -> Future<Rating> {
        let authId = try req.getAuthId()
        let reviewedId = try req.parameters.next(Int.self)
        return Rating.get(authId: authId, reviewedId: reviewedId, on: req)
    }
    
    func create(_ req: Request) throws -> Future<HTTPStatus> {
        
        let authId = try req.getAuthId()
        return try req.content.decode(Rating.Input.self).flatMap { input in
            return Rating.create(authId: authId, input: input, on: req)
        }
    }
    
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        
        let authId = try req.getAuthId()
        return try req.content.decode(Rating.Input.self).flatMap { input in
            return Rating.get(authId: authId, reviewedId: input.reviewedId, on: req).flatMap { rating in
                return rating.update(input: input, on: req)
            }
        }
    }
    
}
