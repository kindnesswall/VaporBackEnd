//
//  GiftRequestDateMigration.swift
//  
//
//  Created by AmirHossein on 7/23/22.
//

import Vapor
import Fluent

struct GiftRequestDateMigration: Migration {
    private let schema = "GiftRequest"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .field("createdAt", .datetime)
            .field("updatedAt", .datetime)
            .field("deletedAt", .datetime)
            .field("expiresAt", .datetime)
            .update()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteField("createdAt")
            .deleteField("updatedAt")
            .deleteField("deletedAt")
            .deleteField("expiresAt")
            .update()
    }
}
