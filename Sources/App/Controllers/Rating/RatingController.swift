//
//  RatingController.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor

final class RatingController {
    
    func create(_ req: Request) throws -> Future<HTTPStatus> {
        
        let authId = try req.getAuthId()
        return try req.content.decode(Rating.Input.self).flatMap { input in
            return Rating.create(authId: authId, input: input, on: req)
        }
    }
    
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        
        let authId = try req.getAuthId()
        return try req.content.decode(Rating.Input.self).flatMap { input in
            return Rating.get(authId: authId, input: input, on: req).flatMap { rating in
                return rating.update(input: input, on: req)
            }
        }
    }
    
}
