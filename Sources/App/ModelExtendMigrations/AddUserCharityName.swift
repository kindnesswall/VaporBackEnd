//
//  AddUserCharityName.swift
//  App
//
//  Created by Amir Hossein on 2/12/20.
//

import FluentPostgreSQL

final class AddUserCharityName: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(User.self, on: conn) { builder in
            builder.field(for: \.charityName)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(User.self, on: conn) { builder in
            builder.deleteField(for: \.charityName)
        }
    }
}
