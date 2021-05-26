//
//  UserPushNotification.swift
//  App
//
//  Created by Amir Hossein on 6/27/19.
//

import Vapor
import Fluent

final class UserPushNotification: Model {
    
    static let schema = "UserPushNotification"
    
    @ID(key: .id)
    var id: Int?
    
    @Field(key: "userId")
    var userId: Int
    
    @Field(key: "userTokenId")
    var userTokenId: Int
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "devicePushToken")
    var devicePushToken: String
    
    init() {}
    
    init(userId: Int, userTokenId: Int, input: Inputs.UserPushNotification) {
        self.userId = userId
        self.userTokenId = userTokenId
        self.type = input.type
        self.devicePushToken = input.devicePushToken
    }
    
    static func hasFound(input: Inputs.UserPushNotification, conn: Database)->EventLoopFuture<UserPushNotification?> {
        return query(on: conn)
            .filter(\.type == input.type)
            .filter(\.devicePushToken == input.devicePushToken)
            .first()
    }
    
    static func findAllTokens(userId:Int, conn: Database) -> EventLoopFuture<[UserPushNotification]>{
        return query(on: conn)
            .filter(\.userId == userId)
            .all()
    }
    
    static func deleteAll(userId: Int, conn: Database) -> EventLoopFuture<HTTPStatus> {
        return query(on: conn)
            .filter(\.userId == userId)
            .delete()
            .transform(to: .ok)
    }
    
    static func delete(userTokenId: Int, conn: Database) -> EventLoopFuture<HTTPStatus> {
        return query(on: conn)
            .filter(\.userTokenId == userTokenId)
            .delete()
            .transform(to: .ok)
    }
    
}

final class SendPushInput : Content {
    let userId:Int
    let title:String?
    let body:String
}

enum PushNotificationType: String, Codable {
    case APNS
    case Firebase
}

//extension UserPushNotification : Migration {}

extension UserPushNotification : Content {}

