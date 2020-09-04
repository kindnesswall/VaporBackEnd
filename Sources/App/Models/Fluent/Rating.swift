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
    
    static func get(authId: Int, input: Input, on req: Request) -> Future<Rating> {
        let item = Rating(authId: authId, input: input)
        
        return _findFirst(input: item, on: req)
            .unwrap(or: Abort(.notFound))
    }
    
    
    static func create(authId: Int, input: Input, on req: Request) -> Future<HTTPStatus> {
        guard input.isValid else {
            return req.future(error: Abort(.invalid))
        }
        let item = Rating(authId: authId, input: input)
        
        return Rating.mustNotFind(input: item, on: req).flatMap { _ in
            return item.create(on: req).flatMap { _ in
                return Self.updateAverageRate(reviewedId: item.reviewedId,
                                              on: req)
            }
        }
    }
    
    func update(input: Input, on req: Request) -> Future<HTTPStatus> {
        guard input.isValid else {
            return req.future(error: Abort(.invalid))
        }
        update(rate: input.rate)
        return update(on: req).flatMap { _ in
            return Self.updateAverageRate(reviewedId: self.reviewedId,
                                          on: req)
        }
        
    }
}

extension Rating: FindOrCreatable {
    static func _findQuery(input: Rating, on conn: DatabaseConnectable) -> QueryBuilder<PostgreSQLDatabase, Rating> {
        return query(on: conn)
            .filter(\.voterId == input.voterId)
            .filter(\.reviewedId == input.reviewedId)
    }
}

extension Rating {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension Rating {
    
    static func averageRate(reviewedId: Int, on conn: DatabaseConnectable) -> Future<Double?> {
        return query(on: conn)
            .filter(\.reviewedId == reviewedId)
            .all()
            .map { $0.averageRate }
    }
    
    static func updateAverageRate(reviewedId: Int, on conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return Rating.averageRate(reviewedId: reviewedId, on: conn)
            .unwrap(or: Abort(.notFound))
            .flatMap { averageRate in
                return RatingResult.set(reviewedId: reviewedId, averageRate: averageRate, on: conn)
        }
    }
}

extension Rating : Migration {}

extension Rating : Content {}

extension Rating : Parameter {}

extension Array where Element == Rating {

    var averageRate: Double? {
        var sum = 0
        for element in self {
            sum += element.rate
        }
        return count > 0 ? (Double(sum) / Double(count)) : nil
    }
}
