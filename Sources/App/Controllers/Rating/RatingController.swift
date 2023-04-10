//
//  RatingController.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor

final class RatingController {
    
    func get(_ req: Request) throws -> EventLoopFuture<Outputs.Rating> {
        
        let reviewedId = try req.requireIDParameter()
        let authId = try? req.requireAuthID()
        
        return RatingResult.get(
            reviewedId: reviewedId,
            on: req.db).flatMap { ratingResult in
                
                var output = Outputs
                    .Rating(userRate: nil,
                            averageRate: ratingResult?.averageRate,
                            votersCount: ratingResult?.votersCount ?? 0)
                
                if let authId = authId {
                    return Rating.find(
                        authId: authId,
                        reviewedId: reviewedId,
                        on: req).map { userRate in
                            output.userRate = userRate?.rate
                            return output
                    }
                } else {
                    return req.db.makeSucceededFuture(output)
                }
        }
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let authId = try req.requireAuthID()
        let input = try req.content.decode(Rating.Input.self)
        return Rating.create(
            authId: authId,
            input: input,
            on: req)
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let authId = try req.requireAuthID()
        let input = try req.content.decode(Rating.Input.self)
        
        return Rating.find(
            authId: authId,
            reviewedId: input.reviewedUserId,
            on: req)
            .unwrap(or: Abort(.notFound))
            .flatMap { rating in
                return rating.update(
                    input: input,
                    on: req)
        }
    }
}
