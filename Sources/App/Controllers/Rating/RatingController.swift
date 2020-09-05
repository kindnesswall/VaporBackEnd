//
//  RatingController.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor

final class RatingController {
    
    func get(_ req: Request) throws -> Future<Outputs.Rating> {
        
        let reviewedId = try req.parameters.next(Int.self)
        let authId = try? req.getAuthId()
        
        return RatingResult.get(reviewedId: reviewedId, on: req).flatMap { ratingResult in
            
            var output = Outputs
                .Rating(userRate: nil,
                        averageRate: ratingResult?.averageRate,
                        votersCount: ratingResult?.votersCount ?? 0)
            
            if let authId = authId {
                return Rating.find(authId: authId, reviewedId: reviewedId, on: req).map { userRate in
                    output.userRate = userRate?.rate
                    return output
                }
            } else {
                return req.future(output)
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
            return Rating.find(authId: authId, reviewedId: input.reviewedUserId, on: req)
                .unwrap(or: Abort(.notFound))
                .flatMap { rating in
                    return rating.update(input: input, on: req)
            }
        }
    }
    
}
