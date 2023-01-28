//
//  CharityLogMigration.swift
//  
//
//  Created by AmirHossein on 1/17/23.
//

import Vapor
import Fluent

struct CharityLogMigration: AsyncMigration {
    private let schema = "CharityLog"
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("charityId", .int)
            .field("charity", .dictionary, .required)
            .field("createdAt", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema)
            .delete()
    }
    
}
