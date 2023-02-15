
//
//  UserPushNotificationV2Migration.swift
//  
//
//  Created by AmirHossein on 2/2/23.
//

import FluentKit

struct UserPushNotificationV2Migration: AsyncMigration {
    private let schema = "UserPushNotificationV2"
    
    func prepare(on database: Database) async throws {
        let userPushNotificationType = try await database
            .enum("UserPushNotificationType")
            .case("APNS")
            .case("Firebase")
            .create()
        try await database.schema(schema)
            .id()
            .field("userId", .int, .required, .references("User", "id"))
            .field("userTokenId", .uuid, .required, .references("TokenV2", "id"))
            .unique(on: "userTokenId")
            .field("type", userPushNotificationType, .required)
            .field("devicePushToken", .string, .required)
            .unique(on: "type", "devicePushToken")
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema)
            .delete()
        try await database.enum("UserPushNotificationType").delete()
    }
    
}
