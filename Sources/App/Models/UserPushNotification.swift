//
//  UserPushNotification.swift
//  App
//
//  Created by Amir Hossein on 6/27/19.
//

import Vapor
import FluentPostgreSQL

final class UserPushNotification: PostgreSQLModel {
    var id: Int?
    var userId: Int
    var userTokenId: Int
    var type: String
    var devicePushToken: String
    
    init(userId: Int, userTokenId: Int, input: Inputs.UserPushNotification) {
        self.userId = userId
        self.userTokenId = userTokenId
        self.type = input.type
        self.devicePushToken = input.devicePushToken
    }
    
    static func hasFound(input: Inputs.UserPushNotification, conn: DatabaseConnectable)->Future<UserPushNotification?> {
        return UserPushNotification.query(on: conn)
            .filter(\.type == input.type)
            .filter(\.devicePushToken == input.devicePushToken)
            .first()
    }
    
    static func findAllTokens(userId:Int, conn: DatabaseConnectable) -> Future<[UserPushNotification]>{
        return UserPushNotification.query(on: conn)
            .filter(\.userId == userId)
            .all()
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

extension UserPushNotification : Migration {}

extension UserPushNotification : Content {}

extension UserPushNotification : Parameter {}
