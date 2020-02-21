//
//  AddGiftCountry.swift
//  App
//
//  Created by Amir Hossein on 2/20/20.
//

import FluentPostgreSQL

final class AddGiftCountry: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(Gift.self, on: conn) { builder in
            builder.field(for: \.countryId)
            builder.field(for: \.countryName)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(Gift.self, on: conn) { builder in
            builder.deleteField(for: \.countryId)
            builder.field(for: \.countryName)
        }
    }
}
