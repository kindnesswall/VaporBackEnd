//
//  Token.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Vapor
import FluentPostgreSQL
import Authentication

final class Token: PostgreSQLModel {
    var id: Int?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }

}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension Token: Authentication.Token {
    typealias UserType = User
    
    static var userIDKey: UserIDKey{
        return \Token.userID
    }
    
    static var tokenKey: TokenKey {
        return \Token.token
    }
}


extension Token : Migration {}
extension Token : Content {}
extension Token : Parameter {}
