//
//  CharityDeletingRegisterIdAndMoreFieldsMigration.swift
//  
//
//  Created by AmirHossein on 7/30/22.
//

import Vapor
import Fluent

struct CharityDeletingRegisterIdAndMoreFieldsMigration: Migration {
    private let schema = "Charity"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteField("imageUrl")
            .deleteField("registerId")
            .deleteField("registerDate")
            .update()
        
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .field("imageUrl", .string)
            .field("registerId", .string)
            .field("registerDate", .string)
            .update()
    }
}
