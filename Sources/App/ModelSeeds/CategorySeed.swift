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
        Category(title:"Others", title_fa: "دیگر موارد"),
        Category(title:"Laptop", title_fa: "لپتاپ"),
        Category(title:"Phone", title_fa: "موبایل"),
        Category(title:"Tablet", title_fa: "تبلت"),
        Category(title:"Clothes", title_fa: "لباس"),
        Category(title:"Shoes", title_fa: "کفش"),
        Category(title:"Book", title_fa: "کتاب"),
        Category(title:"Home Appliance", title_fa: "وسایل منزل")
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
