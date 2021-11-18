//
//  UserUniquePhoneNumberMigration.swift
//  
//
//  Created by Amir Hossein on 11/16/21.
//

import Vapor
import Fluent

struct UserUniquePhoneNumberMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("User")
            .unique(on: "phoneNumber")
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("User")
            .deleteUnique(on: "phoneNumber")
            .update()
    }
}
