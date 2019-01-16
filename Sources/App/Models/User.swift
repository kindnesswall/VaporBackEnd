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
    var password:String
    
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: BasicAuthenticatable {
    static var usernameKey: UsernameKey {
        return \.phoneNumber
    }
    
    static var passwordKey: PasswordKey {
        return \User.password
    }
}

extension User : Migration {
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.phoneNumber)
        }
    }
}

extension User : Content {}

extension User : Parameter {}
