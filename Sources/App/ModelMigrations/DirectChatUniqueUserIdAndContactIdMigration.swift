//
//  DirectChatUniqueUserIdAndContactIdMigration.swift
//  
//
//  Created by Amir Hossein on 11/17/21.
//

import Vapor
import Fluent

struct DirectChatUniqueUserIdAndContactIdMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("DirectChat")
            .unique(on: "userId", "contactId")
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("DirectChat")
            .deleteUnique(on: "userId", "contactId")
            .update()
    }
}
