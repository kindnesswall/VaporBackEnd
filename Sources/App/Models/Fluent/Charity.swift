//
//  Charity.swift
//  app
//
//  Created by Hamed Ghadirian on 10.07.19.
//  Copyright © 2019 Hamed.Gh. All rights reserved.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class Charity: PostgreSQLModel {
    var id: Int?
    var userId:Int?
    var isRejected:Bool? = false
    var rejectReason: String?
    
    var name: String
    var imageUrl: String?
    var registerId: String?
    var registerDate: String?
    var address: String?
    var telephoneNumber: String?
    var mobileNumber: String?
    var website: String?
    var email: String?
    var instagram: String?
    var telegram: String?
    var description: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    init(input: Input, userId:Int) {
        
        self.userId = userId
        
        self.name = input.name
        self.imageUrl = input.imageUrl
        self.registerId = input.registerId
        self.registerDate = input.registerDate
        self.address = input.address
        self.telephoneNumber = input.telephoneNumber
        self.mobileNumber = input.mobileNumber
        self.website = input.website
        self.email = input.email
        self.instagram = input.instagram
        self.telegram = input.telegram
        self.description = input.description
    }
    
    func update(input: Input) {
        self.name = input.name
        self.imageUrl = input.imageUrl
        self.registerId = input.registerId
        self.registerDate = input.registerDate
        self.address = input.address
        self.telephoneNumber = input.telephoneNumber
        self.mobileNumber = input.mobileNumber
        self.website = input.website
        self.email = input.email
        self.instagram = input.instagram
        self.telegram = input.telegram
        self.description = input.description
        
        self.isRejected = false
//        self.rejectReason = nil // Note: Commented because the reason may be helpful for the next review
        
    }
    
    
    final class Input : Codable {
        var name: String
        var imageUrl: String?
        var registerId: String?
        var registerDate: String?
        var address: String?
        var telephoneNumber: String?
        var mobileNumber: String?
        var website: String?
        var email: String?
        var instagram: String?
        var telegram: String?
        var description: String?
    }
}

extension Charity {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension Charity {
    
    static func getAllCharities(conn:DatabaseConnectable) -> EventLoopFuture<[(User,Charity)]> {
        return User.query(on: conn)
            .filter(\.isCharity == true)
            .join(\Charity.userId, to: \User.id)
            .filter(\Charity.deletedAt == nil)
            .alsoDecode(Charity.self)
            .all()
    }
    
    static func getCharityReviewList(conn:DatabaseConnectable) -> EventLoopFuture<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.isRejected == false)
            .join(\User.id, to: \Charity.userId)
            .filter(\User.deletedAt == nil)
            .filter(\User.isCharity == false)
            .all()
    }
    
    static func getCharityRejectedList(conn:DatabaseConnectable) -> EventLoopFuture<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.isRejected == true)
            .join(\User.id, to: \Charity.userId)
            .filter(\User.deletedAt == nil)
            .all()
    }
}

extension Charity {
    static func find(userId: Int, on conn: DatabaseConnectable) -> EventLoopFuture<Charity?> {
        return Charity.query(on: conn).filter(\.userId == userId).first()
    }
    
    static func hasFound(userId: Int, on conn: DatabaseConnectable) -> EventLoopFuture<Bool> {
        return find(userId: userId, on: conn).map { $0 != nil }
    }
    
    static func get(userId: Int , on conn: DatabaseConnectable) throws -> EventLoopFuture<Charity> {
        return find(userId: userId, on: conn).unwrap(or: Abort(.charityInfoNotFound))
    }
}

extension Charity : Migration {}

extension Charity : Content {}

extension Charity : Parameter {}


final class Charity_Status: Content {
    
    var charity: Charity?
    var status: CharityStatus
    
    init(charity: Charity?, status: CharityStatus) {
        self.charity = charity
        self.status = status
    }
}

enum CharityStatus: String, Content {
    case notRequested
    case pending
    case rejected
    case isCharity
}
