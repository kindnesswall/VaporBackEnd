
//
//  TokenV2Migration.swift
//  
//
//  Created by AmirHossein on 2/2/23.
//

import FluentKit

struct TokenV2Migration: AsyncMigration {
    private let schema = "TokenV2"
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("token", .string, .required)
            .unique(on: "token")
            .field("userId", .int, .required, .references("User", "id"))
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .field("deletedAt", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema)
            .delete()
    }
}
