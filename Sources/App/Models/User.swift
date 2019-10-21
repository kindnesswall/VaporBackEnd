//
//  User.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Vapor
import FluentPostgreSQL
import Authentication

final class User : PostgreSQLModel {
    var id:Int?
    var phoneNumber:String
    var activationCode:String?
    var isAdmin:Bool = false
    var isCharity:Bool = false
    var name:String?
    var image:String?
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    func getId() throws -> Int {
        guard let id = self.id else {
            throw Constants.errors.nilUserId
        }
        return id
    }
    
    func getIdFuture(req:Request) -> Future<Int> {
        guard let id = self.id else {
            return req.eventLoop.newFailedFuture(error: Constants.errors.nilUserId)
        }
        return req.eventLoop.newSucceededFuture(result: id)
    }
    
    init(phoneNumber:String) {
        self.phoneNumber=phoneNumber
    }
}

extension User {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension User {
    func userProfile(req:Request) throws -> UserProfile {
        let id = try self.getId()
        let auth = try? req.requireAuthenticated(User.self)
        let phoneNumber = (auth?.isAdmin == true || auth?.isCharity == true || id == auth?.id) ? self.phoneNumber : nil
        let userProfile = UserProfile(id: id, name: self.name, image: self.image, phoneNumber: phoneNumber)
        return userProfile
    }
}

extension User {
    static func phoneNumberHasExisted(phoneNumber:String,conn:DatabaseConnectable)->Future<Bool>{
        return User.query(on: conn, withSoftDeleted: true).filter(\User.phoneNumber == phoneNumber).count().map { count in
            if count != 0 { return true }
            else { return false }
        }
    }
} 

extension User {
    static func allActiveUsers(conn:DatabaseConnectable,requestInput:RequestInput?) -> Future<[User]> {
        let query =  User.query(on: conn)
        return self.getUsersWithRequestFilter(query: query, requestInput: requestInput)
    }
    static func allBlockedUsers(conn:DatabaseConnectable,requestInput:RequestInput?) -> Future<[User]> {
        let query = User.query(on: conn, withSoftDeleted: true).filter(\.deletedAt != nil)
        return self.getUsersWithRequestFilter(query: query, requestInput: requestInput)
    }
    static func allChatBlockedUsers(conn:DatabaseConnectable) -> Future<[(User,ChatBlock)]> {
        return User.query(on: conn).join(\ChatBlock.blockedUserId, to: \User.id).alsoDecode(ChatBlock.self).all()
    }
}

extension User {
    
    static func getUsersWithRequestFilter(query:QueryBuilder<PostgreSQLDatabase, User>,requestInput:RequestInput?)->Future<[User]>{
        
        if let beforeId = requestInput?.beforeId {
            query.filter(\.id < beforeId)
        }
        
        let maximumCount = Constants.maximumRequestFetchResultsCount
        var count = requestInput?.count ?? maximumCount
        if count > maximumCount {
            count = maximumCount
        }
        
        return query.sort(\.id, .descending).range(0..<count).all()
    }
}

extension User {
    static func generateActivationCode()-> String {
        let randomActivationCode = AppRandom.randomNumericString(count: 5)
        return randomActivationCode
    }
}

extension User {
    var gifts : Children<User,Gift> {
        return children(\.userId)
    }
    var receivedGifts : Children<User,Gift>{
        return children(\.donatedToUserId)
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User : Migration {}

extension User : Content {}

extension User : Parameter {}


