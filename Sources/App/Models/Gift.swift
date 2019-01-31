//
//  Gift.swift
//  App
//
//  Created by Amir Hossein on 1/10/19.
//

import Vapor
import FluentPostgreSQL

final class Gift : PostgreSQLModel {
    var id:Int?
    var userId:Int?
    var title:String
    var address:String
    var description:String
    var price:String
    var categoryId:Int
    var images:[String]
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
}

extension Gift {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
    
}

extension Gift {
    var user : Parent<Gift,User> {
        return parent(\.userId)!
    }
    var category : Parent<Gift,Category> {
        return parent(\.categoryId)
    }
}

extension Gift {
    
    static func getGiftsWithRangeFilter(query:QueryBuilder<PostgreSQLDatabase, Gift>,requestRange:RequestRange?)->Future<[Gift]>{
        
        if let beforeId = requestRange?.beforeId {
            query.filter(\.id < beforeId)
        }
        
        let maximumCount = Constants.maximumRequestFetchResultsCount
        var unwrappedCount = requestRange?.count ?? maximumCount
        
        if unwrappedCount > maximumCount {
            unwrappedCount = maximumCount
        }
        
        return query.sort(\.id, PostgreSQLDirection.descending).range(0..<unwrappedCount).all()
    }
    
    
}

/// Allows `Gift` to be used as a dynamic migration.
extension Gift : Migration {}

/// Allows `Gift` to be encoded to and decoded from HTTP messages.
extension Gift : Content {}

/// Allows `Gift` to be used as a dynamic parameter in route definitions.
extension Gift : Parameter {}
