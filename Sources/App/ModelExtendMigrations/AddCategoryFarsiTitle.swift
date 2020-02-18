//
//  AddCategoryFarsiTitle.swift
//  App
//
//  Created by Amir Hossein on 2/18/20.
//

import FluentPostgreSQL

final class AddCategoryFarsiTitle: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(Category.self, on: conn) { builder in
            builder.field(for: \.title_fa)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(Category.self, on: conn) { builder in
            builder.deleteField(for: \.title_fa)
        }
    }
}
