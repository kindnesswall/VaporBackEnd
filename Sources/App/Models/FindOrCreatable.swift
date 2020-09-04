//
//  FindOrCreatable.swift
//  App
//
//  Created by Amir Hossein on 6/4/20.
//

import Vapor
import FluentPostgreSQL

protocol FindOrCreatable: PostgreSQLModel {
    static func _findQuery(input: Self, on conn: DatabaseConnectable) -> QueryBuilder<PostgreSQLDatabase, Self>
    static func _findFirst(input: Self, on conn: DatabaseConnectable) -> Future<Self?>
    static func _count(input: Self, on conn: DatabaseConnectable) -> Future<Int>
    static func mustBeUnique(input: Self, on conn: DatabaseConnectable) -> Future<HTTPStatus>
    static func mustNotFind(input: Self, on conn: DatabaseConnectable) -> Future<HTTPStatus>
    static func _findOrCreate(input: Self, on conn: DatabaseConnectable) -> Future<Self>
}

extension FindOrCreatable {
    
    static func _findFirst(input: Self, on conn: DatabaseConnectable) -> Future<Self?> {
        return _findQuery(input: input, on: conn).first()
    }
    
    static func _count(input: Self, on conn: DatabaseConnectable) -> Future<Int> {
        return _findQuery(input: input, on: conn).count()
    }
    
    static func mustBeUnique(input: Self, on conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return _count(input: input, on: conn).map { count in
            guard count == 1 else {
                throw Abort(.transactionFailed)
            }
            return .ok
        }
    }
    
    static func mustNotFind(input: Self, on conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return _count(input: input, on: conn).map { count in
            guard count == 0 else {
                throw Abort(.alreadyExists)
            }
            return .ok
        }
    }
    
    static func _findOrCreate(input: Self, on conn: DatabaseConnectable) -> Future<Self> {
        
        return _findFirst(input: input, on: conn).flatMap { foundItem in
           
            if let foundItem = foundItem {
                return conn.future(foundItem)
            }
            return conn.transaction(on: .psql) { conn in
                return input.create(on: conn).flatMap { input in
                    return mustBeUnique(input: input, on: conn)
                        .transform(to: input)
                }
            }
        }
        
    }
    
}
