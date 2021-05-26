//
//  FindOrCreatable.swift
//  App
//
//  Created by Amir Hossein on 6/4/20.
//

import Vapor
import Fluent
import FluentPostgresDriver

protocol FindOrCreatable: PostgreSQLModel {
    static func _findQuery(input: Self, on conn: Database) -> QueryBuilder<PostgreSQLDatabase, Self>
    static func _findFirst(input: Self, on conn: Database) -> EventLoopFuture<Self?>
    static func _count(input: Self, on conn: Database) -> EventLoopFuture<Int>
    static func mustBeUnique(input: Self, on conn: Database) -> EventLoopFuture<HTTPStatus>
    static func mustNotFind(input: Self, on conn: Database) -> EventLoopFuture<HTTPStatus>
    static func _findOrCreate(input: Self, on conn: Database) -> EventLoopFuture<Self>
}

extension FindOrCreatable {
    
    static func _findFirst(input: Self, on conn: Database) -> EventLoopFuture<Self?> {
        return _findQuery(input: input, on: conn).first()
    }
    
    static func _count(input: Self, on conn: Database) -> EventLoopFuture<Int> {
        return _findQuery(input: input, on: conn).count()
    }
    
    static func mustBeUnique(input: Self, on conn: Database) -> EventLoopFuture<HTTPStatus> {
        return _count(input: input, on: conn).map { count in
            guard count == 1 else {
                throw Abort(.transactionFailed)
            }
            return .ok
        }
    }
    
    static func mustNotFind(input: Self, on conn: Database) -> EventLoopFuture<HTTPStatus> {
        return _count(input: input, on: conn).map { count in
            guard count == 0 else {
                throw Abort(.alreadyExists)
            }
            return .ok
        }
    }
    
    static func _findOrCreate(input: Self, on conn: Database) -> EventLoopFuture<Self> {
        
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
