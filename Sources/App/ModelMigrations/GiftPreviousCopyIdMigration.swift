//
//  GiftPreviousCopyIdMigration.swift
//  
//
//  Created by AmirHossein on 1/11/23.
//

import Vapor
import Fluent

struct GiftPreviousCopyIdMigration: Migration {
    private let schema = "Gift"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .field("previousCopyId", .int)
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteField("previousCopyId")
            .update()
    }
}
