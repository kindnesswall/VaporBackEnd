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
    
    init(phoneNumber:String) {
        self.phoneNumber=phoneNumber
    }
}

extension User {
    static func generateActivationCode() throws -> String {
        let random = try CryptoRandom().generateData(count: 6)
        return random.base64EncodedString()
    }
}

extension User {
    var gifts : Children<User,Gift> {
        return children(\.userId)
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User : Migration {}

extension User : Content {}

extension User : Parameter {}
