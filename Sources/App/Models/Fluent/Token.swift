
//
//  Token.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Vapor
import Fluent

final class Token: Model {
    
    static let schema = "TokenV2"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "userId")
    var user: User
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(token: String, userId: User.IDValue) {
        self.token = token
        self.$user.id = userId
    }
    
    var outputObject: Output {
        .init(
            token: token,
            userID: $user.id,
            createdAt: createdAt,
            updatedAt: updatedAt)
    }
    
    struct Output: Content {
        //TODO: question: is id required for front end?
        let token: String
        //TODO: rename userID to userId
        let userID: Int?
        let createdAt: Date?
        let updatedAt: Date?
    }
}

extension Token {
    
    static func getAllOldTokensQuery(on db: Database) -> QueryBuilder<Token> {
        let timeInterval = TimeInterval(-1 * 60 * 60 * 24 * 365)
        let date = Date()
            .addingTimeInterval(timeInterval)
        return query(on: db)
            .filter(\.$createdAt < date)
    }
    
    static func getAdminsOldTokensQuery(on db: Database) -> QueryBuilder<Token> {
        let timeInterval = TimeInterval(-1 * 60 * 60 * 24)
        let date = Date()
            .addingTimeInterval(timeInterval)
        return query(on: db)
            .filter(\.$createdAt < date)
            .join(User.self, on: \Token.$user.$id == \User.$id)
            .filter(User.self, \User.$isAdmin == true)
    }
}

extension Token {
    static func generate(for userId: Int) -> Token {
        return Token(
            token: [UInt8].random(count: 16).base64,
            userId: userId)
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

