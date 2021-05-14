//
//  User.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Vapor
import FluentSQL
import Fluent
import FluentPostgresDriver

final class User : PostgreSQLModel {
    var id:Int?
    var phoneNumber:String
    var activationCode:String?
    var isAdmin:Bool = false
    var isCharity:Bool = false
    var name:String?
    var image:String?
    
    var charityName:String?
    var charityImage:String?
    
    var isPhoneVisibleForCharities: Bool? = true
    var isPhoneVisibleForAll: Bool? = false

    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    func getId() throws -> Int {
        guard let id = self.id else {
            throw Abort(.nilUserId)
        }
        return id
    }
    
    func getIdFuture(req:Request) -> EventLoopFuture<Int> {
        guard let id = self.id else {
            return req.future(error: Abort(.nilUserId))
        }
        return req.future(id)
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
        let phoneNumber = (auth?.isAdmin == true || id == auth?.id) ? self.phoneNumber : nil
        
        let charityName = self.isCharity ? self.charityName : nil
        let charityImage = self.isCharity ? self.charityImage : nil
        
        let isSupporter = self.isAdmin
        
        let userProfile = UserProfile(
            id: id,
            name: self.name,
            image: self.image,
            phoneNumber: phoneNumber,
            isCharity: self.isCharity,
            charityName: charityName,
            charityImage: charityImage,
            isSupporter: isSupporter)
        
        return userProfile
    }
}

extension User {
    func change(toPhoneNumber: String, on conn: DatabaseConnectable) -> EventLoopFuture<User> {
        self.phoneNumber = toPhoneNumber
        return save(on: conn)
    }
}

extension User {
    static func get(_ id: Int, on conn: DatabaseConnectable) -> EventLoopFuture<User> {
        return find(id, on: conn).unwrap(or: Abort(.userNotFound))
    }
    static func get(_ id: Int, withSoftDeleted: Bool, on conn: DatabaseConnectable) -> EventLoopFuture<User> {
        return query(on: conn, withSoftDeleted: withSoftDeleted).filter(\.id == id).first().unwrap(or: Abort(.userNotFound))
    }
}

extension User {
    
    static func find(req: Request, phoneNumber: String) -> EventLoopFuture<User?> {
        
        return User.query(on: req, withSoftDeleted: true).filter(\User.phoneNumber == phoneNumber).first().map({ foundUser in
            
            guard foundUser?.deletedAt == nil else {
                throw Abort(.userAccessIsDenied)
            }
            
            return foundUser
        })
    }
    
    static func isNotDeleted(req: Request, phoneNumber: String) -> EventLoopFuture<HTTPStatus> {
        return User.find(req: req, phoneNumber: phoneNumber).transform(to: .ok)
    }
    
    static func phoneNumberHasExisted(phoneNumber:String,conn:DatabaseConnectable)->EventLoopFuture<Bool>{
        return User.query(on: conn, withSoftDeleted: true).filter(\User.phoneNumber == phoneNumber).count().map { count in
            if count != 0 { return true }
            else { return false }
        }
    }
} 

extension User {
    static func allActiveUsers(on conn: DatabaseConnectable, queryParam: Inputs.UserQuery?) -> EventLoopFuture<[User]> {
        let query =  User.query(on: conn)
        return self.getUsersWithRequestFilter(query: query, queryParam: queryParam)
    }
    static func allBlockedUsers(on conn: DatabaseConnectable, queryParam: Inputs.UserQuery?) -> EventLoopFuture<[User]> {
        let query = User.query(on: conn, withSoftDeleted: true).filter(\.deletedAt != nil)
        return self.getUsersWithRequestFilter(query: query, queryParam: queryParam)
    }
}

extension User {
    static func allChatBlockedUsers(on conn: DatabaseConnectable) -> EventLoopFuture<[User_BlockedReport]> {
        return User.query(on: conn).join(\ChatBlock.blockedUserId, to: \User.id).alsoDecode(ChatBlock.self).all().map { $0.getStandard() }
    }
}

extension User {
    
    static func getUsersWithRequestFilter(query: QueryBuilder<PostgreSQLDatabase, User>, queryParam: Inputs.UserQuery?) -> EventLoopFuture<[User]> {
        
        if let phoneNumber = queryParam?.phoneNumber {
            query.filter(\.phoneNumber ~~ phoneNumber)
        }
        
        if let beforeId = queryParam?.beforeId {
            query.filter(\.id < beforeId)
        }
        
        let count = Constants.maxFetchCount(bound: queryParam?.count)
        
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


