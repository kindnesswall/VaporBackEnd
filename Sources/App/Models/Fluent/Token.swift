//
//  Token.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Vapor
import Fluent

final class Token: Model {
    
    static let schema = "Token"
    
    @ID(key: .id)
    var id: Int?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "userID")
    var user: User
    
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(token: String, userID: User.IDValue) {
        self.token = token
        self.$user.id = userID
    }

}

extension Token {
    func getId() throws -> Int {
        guard let id = self.id else {
            throw Abort(.nilTokenId)
        }
        return id
    }
}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$token
    static let userKey = \Token.$user

    var isValid: Bool {
        true
    }
}


//extension Token : Migration {}
extension Token : Content {}

