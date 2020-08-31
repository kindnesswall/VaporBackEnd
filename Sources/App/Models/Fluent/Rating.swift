//
//  Rating.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor
import FluentPostgreSQL

final class Rating: PostgreSQLModel {
    var id: Int?
    var reviewedId: Int
    var rate: Int
    var voterId: Int
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    private init(authId voterId: Int, input: Input) {
        self.voterId = voterId
        self.reviewedId = input.reviewedId
        self.rate = input.rate
    }
    
    private func update(rate: Int) {
        self.rate = rate
    }
}

extension Rating {
    struct Input: Decodable {
        var reviewedId: Int
        var rate: Int
        
        var isValid: Bool {
            guard rate > 0 , rate <= 5 else { return false }
            return true
        }
    }
}

extension Rating {
    static func create(authId: Int, input: Input, on req: Request) -> Future<HTTPStatus> {
        guard input.isValid else {
            return req.future(error: Abort(.invalid))
        }
        let item = Rating(authId: authId, input: input)
        return item.create(on: req)
            .transform(to: .ok)
    }
    
    func update(input: Input, on req: Request) -> Future<HTTPStatus> {
        guard input.isValid else {
            return req.future(error: Abort(.invalid))
        }
        update(rate: input.rate)
        return update(on: req).transform(to: .ok)
    }
}

extension Rating {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension Rating {
    static func get(authId voterId: Int, reviewedId: Int, on conn: DatabaseConnectable) -> Future<Rating> {
        return query(on: conn)
            .filter(\.voterId == voterId)
            .filter(\.reviewedId == reviewedId)
            .first()
            .unwrap(or: Abort(.notFound))
    }
}

extension Rating : Migration {}

extension Rating : Content {}

extension Rating : Parameter {}
