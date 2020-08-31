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
    var userId: Int
    var averageRate: Int
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
}

extension RatingResult {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension RatingResult : Migration {}

extension RatingResult : Content {}

extension RatingResult : Parameter {}
