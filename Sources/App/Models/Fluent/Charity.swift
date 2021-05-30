//
//  Charity.swift
//  app
//
//  Created by Hamed Ghadirian on 10.07.19.
//  Copyright © 2019 Hamed.Gh. All rights reserved.
//

import Vapor
import Fluent

final class Charity: Model {
    
    static let schema = "Charity"
    
    @ID(key: .id)
    var id: Int?
    
    @OptionalField(key: "userId")
    var userId:Int?
    
    @OptionalField(key: "isRejected")
    var isRejected:Bool? = false
    
    @OptionalField(key: "rejectReason")
    var rejectReason: String?
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "imageUrl")
    var imageUrl: String?
    
    @OptionalField(key: "registerId")
    var registerId: String?
    
    @OptionalField(key: "registerDate")
    var registerDate: String?
    
    @OptionalField(key: "address")
    var address: String?
    
    @OptionalField(key: "telephoneNumber")
    var telephoneNumber: String?
    
    @OptionalField(key: "mobileNumber")
    var mobileNumber: String?
    
    @OptionalField(key: "website")
    var website: String?
    
    @OptionalField(key: "email")
    var email: String?
    
    @OptionalField(key: "instagram")
    var instagram: String?
    
    @OptionalField(key: "telegram")
    var telegram: String?
    
    @OptionalField(key: "description")
    var description: String?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
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
    
    static func getAllCharities(conn:Database) -> EventLoopFuture<[(User,Charity)]> {
        return User.query(on: conn)
            .filter(\.$isCharity == true)
            .join(\Charity.userId, to: \User.id)
            .filter(\Charity.deletedAt == nil)
            .alsoDecode(Charity.self)
            .all()
    }
    
    static func getCharityReviewList(conn:Database) -> EventLoopFuture<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.$isRejected == false)
            .join(\User.id, to: \Charity.userId)
            .filter(\User.deletedAt == nil)
            .filter(\User.isCharity == false)
            .all()
    }
    
    static func getCharityRejectedList(conn:Database) -> EventLoopFuture<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.$isRejected == true)
            .join(\User.id, to: \Charity.userId)
            .filter(\User.deletedAt == nil)
            .all()
    }
}

extension Charity {
    static func find(userId: Int, on conn: Database) -> EventLoopFuture<Charity?> {
        return Charity.query(on: conn).filter(\.$userId == userId).first()
    }
    
    static func hasFound(userId: Int, on conn: Database) -> EventLoopFuture<Bool> {
        return find(userId: userId, on: conn).map { $0 != nil }
    }
    
    static func get(userId: Int , on conn: Database) throws -> EventLoopFuture<Charity> {
        return find(userId: userId, on: conn).unwrap(or: Abort(.charityInfoNotFound))
    }
}

//extension Charity : Migration {}

extension Charity : Content {}



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
