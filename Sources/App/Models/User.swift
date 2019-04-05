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
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    final class Input : Codable {
        var phoneNumber:String
        var activationCode:String?
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
