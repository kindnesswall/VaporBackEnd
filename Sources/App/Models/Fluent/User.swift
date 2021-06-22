//
//  User.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Vapor
import FluentSQL
import Fluent

final class User : Model {
    
    static let schema = "User"
    
    @ID(key: .id)
    var id:Int?
    
    @Field(key: "phoneNumber")
    var phoneNumber:String
    
    @OptionalField(key: "activationCode")
    var activationCode:String?
    
    @Field(key: "isAdmin")
    var isAdmin:Bool
    
    @Field(key: "isCharity")
    var isCharity:Bool
    
    @OptionalField(key: "name")
    var name:String?
    
    @OptionalField(key: "image")
    var image:String?
    
    @OptionalField(key: "charityName")
    var charityName:String?
    
    @OptionalField(key: "charityImage")
    var charityImage:String?
    
    @OptionalField(key: "isPhoneVisibleForCharities")
    var isPhoneVisibleForCharities: Bool?
    
    @OptionalField(key: "isPhoneVisibleForAll")
    var isPhoneVisibleForAll: Bool?

    @Children(for: \.$user)
    var authTokens: [Token]
    
    @Children(for: \.$user)
    var gifts: [Gift]
    
    @Children(for: \.$donatedToUser)
    var receivedGifts: [Gift]
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(phoneNumber:String) {
        self.phoneNumber=phoneNumber
        
        self.isAdmin = false
        self.isCharity = false
        self.isPhoneVisibleForCharities = true
        self.isPhoneVisibleForAll = false
    }
    
    func getId() throws -> Int {
        guard let id = self.id else {
            throw Abort(.nilUserId)
        }
        return id
    }
    
    func getIdFuture(req:Request) -> EventLoopFuture<Int> {
        guard let id = self.id else {
            return req.db.makeFailedFuture(.nilUserId)
        }
        return req.db.makeSucceededFuture(id)
    }
}

extension User: Authenticatable {}

extension User {
    func userProfile(req:Request) throws -> UserProfile {
        let id = try self.getId()
        let auth = try? req.auth.require(User.self)
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
    func change(toPhoneNumber: String, on conn: Database) -> EventLoopFuture<User> {
        self.phoneNumber = toPhoneNumber
        return save(on: conn).transform(to: self)
    }
}

extension User {
    
    static func find(req: Request, phoneNumber: String) -> EventLoopFuture<User?> {
        
        return query(on: req.db)
            .withDeleted()
            .filter(\.$phoneNumber == phoneNumber)
            .first()
            .flatMapThrowing { foundUser in
                
                guard foundUser?.deletedAt == nil else {
                    throw Abort(.userAccessIsDenied)
                }
                
                return foundUser
        }
    }
    
    static func isNotDeleted(req: Request, phoneNumber: String) -> EventLoopFuture<HTTPStatus> {
        return User.find(req: req, phoneNumber: phoneNumber).transform(to: .ok)
    }
    
    static func phoneNumberHasExisted(phoneNumber:String,conn: Database)->EventLoopFuture<Bool>{
        return User.query(on: conn).withDeleted().filter(\User.$phoneNumber == phoneNumber).count().map { count in
            if count != 0 { return true }
            else { return false }
        }
    }
} 

extension User {
    static func allActiveUsers(on conn: Database, queryParam: Inputs.UserQuery?) -> EventLoopFuture<[User]> {
        let query =  User.query(on: conn)
        return self.getUsersWithRequestFilter(query: query, queryParam: queryParam)
    }
    static func allBlockedUsers(on conn: Database, queryParam: Inputs.UserQuery?) -> EventLoopFuture<[User]> {
        let query = User.query(on: conn).withDeleted().filter(\.$deletedAt != nil)
        return self.getUsersWithRequestFilter(query: query, queryParam: queryParam)
    }
}

extension User {
    static func allChatBlockedUsers(on conn: Database) -> EventLoopFuture<[User_BlockedReport]> {
        return User.query(on: conn).join(\ChatBlock.blockedUserId, to: \User.id).alsoDecode(ChatBlock.self).all().map { $0.getStandard() }
    }
}

extension User {
    
    static func getUsersWithRequestFilter(query: QueryBuilder<User>, queryParam: Inputs.UserQuery?) -> EventLoopFuture<[User]> {
        
        if let phoneNumber = queryParam?.phoneNumber {
            query.filter(\.$phoneNumber ~~ phoneNumber)
        }
        
        if let beforeId = queryParam?.beforeId {
            query.filter(\.$id < beforeId)
        }
        
        let count = Constants.maxFetchCount(bound: queryParam?.count)
        
        return query.sort(\.$id, .descending).range(0..<count).all()
    }
}

extension User {
    static func generateActivationCode()-> String {
        let randomActivationCode = AppRandom.randomNumericString(count: 5)
        return randomActivationCode
    }
}

//extension User : Migration {}

extension User : Content {}



