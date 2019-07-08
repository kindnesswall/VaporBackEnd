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
    var deviceIdentifier: String
    var type: String
    var devicePushToken: String
    
    final class Input : Content {
        var deviceIdentifier: String
        var type: String
        var devicePushToken: String
    }
    
    init(userId:Int,input:Input) {
        self.userId = userId
        self.deviceIdentifier = input.deviceIdentifier
        self.type = input.type
        self.devicePushToken = input.devicePushToken
    }
    
    static func hasFound(input:Input,conn:DatabaseConnectable)->Future<UserPushNotification?> {
        return UserPushNotification.query(on: conn)
            .filter(\.deviceIdentifier == input.deviceIdentifier)
            .filter(\.type == input.type)
            .filter(\.devicePushToken == input.devicePushToken)
            .first()
    }
    
    static func findAllTokens(userId:Int, type: String, conn: DatabaseConnectable) -> Future<[UserPushNotification]>{
        return UserPushNotification.query(on: conn)
            .filter(\.userId == userId)
            .filter(\.type == type).all()
    }
    
}

final class SendPushInput : Content {
    let userId:Int
    let text:String
}

enum PushNotificationType: String, Codable {
    case APNS
}

extension UserPushNotification : Migration {}

extension UserPushNotification : Content {}

extension UserPushNotification : Parameter {}
