//
//  RatingResultUniqueReviewedIdMigration.swift
//  
//
//  Created by Amir Hossein on 11/17/21.
//

import Vapor
import Fluent

struct RatingResultUniqueReviewedIdMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("RatingResult")
            .unique(on: "reviewedId")
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("RatingResult")
            .deleteUnique(on: "reviewedId")
            .update()
    }
}
