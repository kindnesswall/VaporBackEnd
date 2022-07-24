//
//  GiftIsDeliveredMigration.swift
//  
//
//  Created by AmirHossein on 7/23/22.
//

import Vapor
import Fluent

struct GiftIsDeliveredMigration: Migration {
    
    private let schema = "Gift"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .field("isDelivered", .bool)
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteField("isDelivered")
            .update()
    }
}
