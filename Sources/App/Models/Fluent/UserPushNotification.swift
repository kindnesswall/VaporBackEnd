
//
//  UserPushNotification.swift
//  App
//
//  Created by Amir Hossein on 6/27/19.
//

import Vapor
import Fluent

final class UserPushNotification: Model {
    
    static let schema = "UserPushNotificationV2"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userId")
    var userId: Int
    
    @Field(key: "userTokenId")
    var userTokenId: UUID
    
    @Enum(key: "type")
    var type: PushNotificationType
    
    @Field(key: "devicePushToken")
    var devicePushToken: String
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(userId: Int, userTokenId: UUID, input: Inputs.UserPushNotification) {
        self.userId = userId
        self.userTokenId = userTokenId
        self.type = input.type
        self.devicePushToken = input.devicePushToken
    }
    
    static func find(
        with userTokenId: UUID,
        or input: Inputs.UserPushNotification,
        on db: Database) -> EventLoopFuture<[UserPushNotification]> {
            return query(on: db)
                .group(.or) { query in
                    query.filter(\.$userTokenId == userTokenId)
                    query.group(.and) { query in
                        query.filter(\.$type == input.type)
                        query.filter(\.$devicePushToken == input.devicePushToken)
                    }
                }
                .all()
        }
    
    static func findAllTokens(userId:Int, conn: Database) -> EventLoopFuture<[UserPushNotification]>{
        return query(on: conn)
            .filter(\.$userId == userId)
            .all()
    }
    
    static func deleteAll(userId: Int, conn: Database) -> EventLoopFuture<HTTPStatus> {
        return query(on: conn)
            .filter(\.$userId == userId)
            .delete()
            .transform(to: .ok)
    }
    
    static func delete(userTokenId: UUID, conn: Database) -> EventLoopFuture<HTTPStatus> {
        return query(on: conn)
            .filter(\.$userTokenId == userTokenId)
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

