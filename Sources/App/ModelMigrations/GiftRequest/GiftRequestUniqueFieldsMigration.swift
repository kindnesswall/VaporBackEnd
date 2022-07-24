//
//  GiftRequestUniqueFieldsMigration.swift
//  
//
//  Created by AmirHossein on 7/23/22.
//

import Vapor
import Fluent

struct GiftRequestUniqueFieldsMigration: Migration {
    
    private let schema = "GiftRequest"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .unique(on: "requestUserId", "giftId")
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteUnique(on: "requestUserId", "giftId")
            .update()
    }
}
