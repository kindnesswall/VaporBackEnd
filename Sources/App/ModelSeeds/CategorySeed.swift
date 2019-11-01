//
//  CategorySeed.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//


import FluentPostgreSQL

final class CategorySeed: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static let seeds = [
        Category(title:"Others"),
        Category(title:"Laptop"),
        Category(title:"Phone"),
        Category(title:"Tablet"),
        Category(title:"Clothes"),
        Category(title:"Shoes"),
        Category(title:"Book"),
        Category(title:"Home Appliance")
    ]
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        let futures = seeds.map { seed in
            return seed.create(on: connection).map(to: Void.self) { _ in return }
        }
        return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        
        let futures = seeds.map { seed in
            return Category.query(on: connection).filter(\Category.title == seed.title).delete()
        }
        return Future<Void>.andAll(futures, eventLoop: connection.eventLoop)
    }
}
