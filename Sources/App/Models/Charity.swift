//
//  Charity.swift
//  app
//
//  Created by Hamed Ghadirian on 10.07.19.
//  Copyright © 2019 Hamed.Gh. All rights reserved.
//

import Vapor
import FluentPostgreSQL

final class Charity: PostgreSQLModel {
    var id: Int?
    var userId:Int?
    var isRejected:Bool? = false
    var rejectReason: String?
    
    var imageUrl: String?
    var name: String
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
}

extension Charity {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension Charity {
    
    static func getAllCharities(conn:DatabaseConnectable) -> Future<[(User,Charity)]> {
        return User.query(on: conn)
            .filter(\.isCharity == true)
            .join(\Charity.userId, to: \User.id)
            .filter(\Charity.deletedAt == nil)
            .alsoDecode(Charity.self)
            .all()
    }
    
    static func getCharityReviewList(conn:DatabaseConnectable) -> Future<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.isRejected == false)
            .join(\User.id, to: \Charity.userId)
            .filter(\User.deletedAt == nil)
            .filter(\User.isCharity == false)
            .all()
    }
    
    static func getCharityRejectedList(conn:DatabaseConnectable) -> Future<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.isRejected == true)
            .join(\User.id, to: \Charity.userId)
            .filter(\User.deletedAt == nil)
            .all()
    }
}

extension Charity {
    static func find(userId:Int,conn:DatabaseConnectable)->Future<Charity?> {
        return Charity.query(on: conn).filter(\.userId == userId).first()
    }
    static func hasFound(userId:Int,conn:DatabaseConnectable)->Future<Bool> {
        return find(userId: userId, conn: conn).map { charity in
            if let _ = charity { return true } else { return false }
        }
    }
    static func get(userId:Int,conn:DatabaseConnectable) throws ->Future<Charity> {
        return find(userId: userId, conn: conn).map({ charity in
            guard let charity = charity else {
                throw Abort(.charityInfoNotFound)
            }
            return charity
        })
    }
    
    func createCharity(userId:Int,conn: DatabaseConnectable) -> Future<Charity> {
        
        self.id = nil
        self.userId = userId
        self.isRejected = false
        self.rejectReason = nil
        
        return self.save(on: conn)
    }
    
    func updateCharity(original:Charity,conn: DatabaseConnectable) -> Future<Charity> {
        
        self.id = original.id
        self.userId = original.userId
        self.isRejected = false
        //self.rejectReason = nil // Note: Commented because Reason of last rejection may help for next review
        
        return self.save(on: conn)
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
