//
//  RatingController.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor

final class RatingController {
    
    func get(_ req: Request) throws -> Future<Outputs.Rating> {
        let authId = try req.getAuthId()
        let reviewedId = try req.parameters.next(Int.self)
        return Rating.find(authId: authId, reviewedId: reviewedId, on: req).flatMap { userRate in
            return RatingResult.get(reviewedId: reviewedId, on: req).map { ratingResult in
                return Outputs
                    .Rating(userRate: userRate?.rate,
                            averageRate: ratingResult?.averageRate,
                            votersCount: ratingResult?.votersCount ?? 0)
            }
        }
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
            return Rating.find(authId: authId, reviewedId: input.reviewedId, on: req)
                .unwrap(or: Abort(.notFound))
                .flatMap { rating in
                    return rating.update(input: input, on: req)
            }
        }
    }
    
}
