//
//  RatingResult.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor
import FluentPostgreSQL

final class RatingResult: PostgreSQLModel {
    var id: Int?
    var reviewedId: Int
    var averageRate: Double
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    init(reviewedId: Int, averageRate: Double) {
        self.reviewedId = reviewedId
        self.averageRate = averageRate
    }
}

extension RatingResult {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension RatingResult {
    static func set(reviewedId: Int, averageRate: Double, on conn: DatabaseConnectable) -> Future<HTTPStatus>  {
        let input = RatingResult(reviewedId: reviewedId, averageRate: averageRate)
        return _findOrCreate(input: input, on: conn).flatMap { item in
            item.averageRate = averageRate
            return item.update(on: conn)
                .transform(to: .ok)
        }
    }
    
    static func get(reviewedId: Int, on conn: DatabaseConnectable) -> Future<RatingResult> {
        return _findQuery(reviewedId: reviewedId, on: conn)
            .first()
            .unwrap(or: Abort(.notFound))
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
