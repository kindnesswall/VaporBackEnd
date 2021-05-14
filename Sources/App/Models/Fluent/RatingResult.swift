//
//  RatingResult.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class RatingResult: PostgreSQLModel {
    var id: Int?
    var reviewedId: Int
    var averageRate: Double
    var votersCount: Int
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    init(reviewedId: Int, averageRate: AverageRate) {
        self.reviewedId = reviewedId
        self.averageRate = averageRate.rate
        self.votersCount = averageRate.votersCount
    }
}

extension RatingResult {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension RatingResult {
    static func set(reviewedId: Int, averageRate: AverageRate, on conn: DatabaseConnectable) -> Future<HTTPStatus>  {
        
        let input = RatingResult(reviewedId: reviewedId, averageRate: averageRate)
        return _findOrCreate(input: input, on: conn).flatMap { item in
            
            item.averageRate = averageRate.rate
            item.votersCount = averageRate.votersCount
            
            return item.update(on: conn)
                .transform(to: .ok)
        }
    }
    
    static func get(reviewedId: Int, on conn: DatabaseConnectable) -> Future<RatingResult?> {
        return _findQuery(reviewedId: reviewedId, on: conn)
            .first()
    }
}

extension RatingResult: FindOrCreatable {
    static func _findQuery(input: RatingResult, on conn: DatabaseConnectable) -> QueryBuilder<PostgreSQLDatabase, RatingResult> {
        
        return _findQuery(reviewedId: input.reviewedId, on: conn)
    }
    
    static func _findQuery(reviewedId: Int, on conn: DatabaseConnectable) -> QueryBuilder<PostgreSQLDatabase, RatingResult> {
        
        return query(on: conn)
            .filter(\.reviewedId == reviewedId)
    }
}

extension RatingResult : Migration {}

extension RatingResult : Content {}

extension RatingResult : Parameter {}
