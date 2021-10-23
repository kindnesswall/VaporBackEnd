//
//  RatingResult.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor
import Fluent

final class RatingResult: Model {
    
    static let schema = "RatingResult"
    
    @ID(custom: .id)
    var id: Int?
    
    @Field(key: "reviewedId")
    var reviewedId: Int
    
    @Field(key: "averageRate")
    var averageRate: Double
    
    @Field(key: "votersCount")
    var votersCount: Int
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(reviewedId: Int, averageRate: AverageRate) {
        self.reviewedId = reviewedId
        self.averageRate = averageRate.rate
        self.votersCount = averageRate.votersCount
    }
}

extension RatingResult {
    static func set(reviewedId: Int, averageRate: AverageRate, on conn: Database) -> EventLoopFuture<HTTPStatus>  {
        
        let input = RatingResult(reviewedId: reviewedId, averageRate: averageRate)
        return _findOrCreate(input: input, on: conn).flatMap { item in
            
            item.averageRate = averageRate.rate
            item.votersCount = averageRate.votersCount
            
            return item.update(on: conn)
                .transform(to: .ok)
        }
    }
    
    static func get(reviewedId: Int, on conn: Database) -> EventLoopFuture<RatingResult?> {
        return _findQuery(reviewedId: reviewedId, on: conn)
            .first()
    }
}

extension RatingResult: FindOrCreatable {
    static func _findQuery(input: RatingResult, on conn: Database) -> QueryBuilder<RatingResult> {
        
        return _findQuery(reviewedId: input.reviewedId, on: conn)
    }
    
    static func _findQuery(reviewedId: Int, on conn: Database) -> QueryBuilder<RatingResult> {
        
        return query(on: conn)
            .filter(\.$reviewedId == reviewedId)
    }
}

//extension RatingResult : Migration {}

extension RatingResult : Content {}


