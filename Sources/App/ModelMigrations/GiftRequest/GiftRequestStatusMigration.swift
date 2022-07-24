//
//  GiftRequestStatusMigration.swift
//  
//
//  Created by AmirHossein on 7/23/22.
//

import Vapor
import Fluent

struct GiftRequestStatusMigration: Migration {
    private let schema = "GiftRequest"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .field("statusDescription", .string)
            .update()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteField("statusDescription")
            .update()
    }
}
