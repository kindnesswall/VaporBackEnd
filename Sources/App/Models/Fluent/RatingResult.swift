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
}

extension RatingResult: FindOrCreatable {
    static func _findQuery(input: RatingResult, on conn: DatabaseConnectable) -> QueryBuilder<PostgreSQLDatabase, RatingResult> {
        
        return query(on: conn)
            .filter(\.reviewedId == input.reviewedId)
    }
}

extension RatingResult : Migration {}

extension RatingResult : Content {}

extension RatingResult : Parameter {}
