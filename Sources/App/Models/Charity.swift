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
    
    static func getCharityReviewList(conn:DatabaseConnectable) -> Future<[(Charity,User)]> {
        return Charity.query(on: conn)
            .filter(\.isRejected == false)
            .join(\User.id, to: \Charity.userId)
            .filter(\User.deletedAt == nil)
            .filter(\User.isCharity == false)
            .alsoDecode(User.self)
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
                throw Constants.errors.charityInfoNotFound
            }
            return charity
        })
    }
    
    func createCharity(userId:Int,conn: DatabaseConnectable) -> Future<Charity> {
        
        self.id = nil
        self.userId = userId
        self.isRejected = false
        
        return self.save(on: conn)
    }
    
    func updateCharity(original:Charity,conn: DatabaseConnectable) -> Future<Charity> {
        
        self.id = original.id
        self.userId = original.userId
        self.isRejected = false
        
        return self.save(on: conn)
    }
}

extension Charity : Migration {}

extension Charity : Content {}

extension Charity : Parameter {}


final class CharityInfoStatus: Content {
    var isCreated: Bool
    var charity: Charity?
    
    init(isCreated: Bool, charity: Charity?) {
        self.isCreated = isCreated
        self.charity = charity
    }
}

final class Charity_UserProfile: Content {
    var charity: Charity
    var userProfile: UserProfile
    
    init(charity: Charity, userProfile: UserProfile) {
        self.charity = charity
        self.userProfile = userProfile
    }
    
    convenience init(charity: Charity, user: User, req:Request) throws {
        let userProfile = try user.userProfile(req: req)
        self.init(charity: charity, userProfile: userProfile)
    }
}
