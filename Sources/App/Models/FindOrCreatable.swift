//
//  FindOrCreatable.swift
//  App
//
//  Created by Amir Hossein on 6/4/20.
//

import Vapor
import FluentPostgreSQL

protocol FindOrCreatable: PostgreSQLModel {
    static func _find(input: Self, on conn: DatabaseConnectable) -> Future<Self?>
    static func _findOrCreate(input: Self, on conn: DatabaseConnectable) -> Future<Self>
}

extension FindOrCreatable {
    
    static func _findOrCreate(input: Self, on conn: DatabaseConnectable) -> Future<Self> {
        
        return _find(input: input, on: conn).flatMap { foundItem in
            if let foundItem = foundItem {
                return conn.future(foundItem)
            }
            return input.save(on: conn)
        }
        
    }
    
}
