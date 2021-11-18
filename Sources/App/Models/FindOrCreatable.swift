//
//  FindOrCreatable.swift
//  App
//
//  Created by Amir Hossein on 6/4/20.
//

import Vapor
import Fluent
import FluentPostgresDriver

protocol FindOrCreatable: Model {
    static func _findQuery(input: Self, on conn: Database) -> QueryBuilder<Self>
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
        return _count(input: input, on: conn).flatMapThrowing { count in
            guard count == 1 else {
                throw Abort(.transactionFailed)
            }
            return .ok
        }
    }
    
    static func mustNotFind(input: Self, on conn: Database) -> EventLoopFuture<HTTPStatus> {
        return _count(input: input, on: conn).flatMapThrowing { count in
            guard count == 0 else {
                throw Abort(.alreadyExists)
            }
            return .ok
        }
    }
    
    static func _findOrCreate(input: Self, on db: Database) -> EventLoopFuture<Self> {
        
        return _findFirst(input: input, on: db).flatMap { foundItem in
            
            if let foundItem = foundItem {
                return db.makeSucceededFuture(foundItem)
            }
            
            return input.create(on: db)
                .transform(to: input)
        }
    }
}
