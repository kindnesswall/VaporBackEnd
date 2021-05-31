//
//  Rating.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor
import Fluent

final class Rating: Model {
    
    static let schema = "Rating"
    
    @ID(key: .id)
    var id: Int?
    
    @Field(key: "reviewedId")
    var reviewedId: Int
    
    @Field(key: "rate")
    var rate: Int
    
    @Field(key: "voterId")
    var voterId: Int
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    private init(authId voterId: Int, input: Input) {
        self.voterId = voterId
        self.reviewedId = input.reviewedUserId
        self.rate = input.rate
    }
    
    private func update(rate: Int) {
        self.rate = rate
    }
}

extension Rating {
    struct Input: Decodable {
        var reviewedUserId: Int
        var rate: Int
        
        var isValid: Bool {
            guard rate > 0 , rate <= 5 else { return false }
            return true
        }
    }
}

extension Rating {
    
    
    
    static func find(authId voterId: Int, reviewedId: Int, on req: Request) -> EventLoopFuture<Rating?> {
        return _findQuery(voterId: voterId, reviewedId: reviewedId, on: req.db)
            .first()
    }
    
    
    static func create(authId: Int, input: Input, on req: Request) -> EventLoopFuture<HTTPStatus> {
        guard input.isValid, authId != input.reviewedUserId  else {
            return req.future(error: Abort(.invalid))
        }
        let item = Rating(authId: authId, input: input)
        
        return Rating.mustNotFind(input: item, on: req.db).flatMap { _ in
            return item.create(on: req.db).flatMap { _ in
                return Rating.updateAverageRate(reviewedId: item.reviewedId,
                                                on: req.db)
            }
        }
    }
    
    func update(input: Input, on req: Request) -> EventLoopFuture<HTTPStatus> {
        guard input.isValid else {
            return req.future(error: Abort(.invalid))
        }
        update(rate: input.rate)
        return update(on: req.db).flatMap { _ in
            return Rating.updateAverageRate(reviewedId: self.reviewedId,
                                            on: req.db)
        }
        
    }
}

extension Rating: FindOrCreatable {
    static func _findQuery(input: Rating, on conn: Database) -> QueryBuilder<Rating> {
        return _findQuery(voterId: input.voterId, reviewedId: input.reviewedId, on: conn)
    }
    
    static func _findQuery(voterId: Int, reviewedId: Int, on conn: Database) -> QueryBuilder<Rating> {
        return query(on: conn)
            .filter(\.$voterId == voterId)
            .filter(\.$reviewedId == reviewedId)
    }
}

extension Rating {
    
    static func calculateAverageRate(reviewedId: Int, on conn: Database) -> EventLoopFuture<AverageRate?> {
        return query(on: conn)
            .filter(\.$reviewedId == reviewedId)
            .all()
            .map { $0.averageRate }
    }
    
    static func updateAverageRate(reviewedId: Int, on conn: Database) -> EventLoopFuture<HTTPStatus> {
        return Rating.calculateAverageRate(reviewedId: reviewedId, on: conn)
            .unwrap(or: Abort(.notFound))
            .flatMap { averageRate in
                return RatingResult.set(reviewedId: reviewedId, averageRate: averageRate, on: conn)
        }
    }
}

//extension Rating : Migration {}

extension Rating : Content {}



struct AverageRate: Content {
    var rate: Double
    var votersCount: Int
}

extension Array where Element == Rating {

    var averageRate: AverageRate? {
        var sum = 0
        for element in self {
            sum += element.rate
        }
        if count > 0 {
            let averageRate = Double(sum) / Double(count)
            return AverageRate(rate: averageRate, votersCount: count)
        } else {
            return nil
        }
    }
}
