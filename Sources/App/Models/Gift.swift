//
//  Gift.swift
//  App
//
//  Created by Amir Hossein on 1/10/19.
//

import Vapor
import FluentPostgreSQL
import FluentSQL

final class Gift : PostgreSQLModel {
    var id:Int?
    var userId:Int?
    var donatedToUserId:Int?
    var isReviewed = false
    var isRejected = false
    var isDeleted = false
    var categoryTitle:String?
    
    var title:String
    var description:String
    var price:String
    var categoryId:Int
    var giftImages:[String]
    var isNew:Bool
    var provinceId:Int
    var cityId:Int
    var regionId:Int?
    var provinceName:String?
    var cityName:String?
    var regionName:String?
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    
    init(userId:Int?,gift:Gift.Input) {
        self.userId = userId
        
        self.title=gift.title
        self.description=gift.description
        self.price=gift.price
        self.categoryId=gift.categoryId
        self.giftImages=gift.giftImages
        self.isNew=gift.isNew
        self.provinceId=gift.provinceId
        self.cityId=gift.cityId
        self.regionId=gift.regionId
    }
    
    func update(gift:Gift.Input) {
        self.title=gift.title
        self.description=gift.description
        self.price=gift.price
        self.categoryId=gift.categoryId
        self.giftImages=gift.giftImages
        self.isNew=gift.isNew
        self.provinceId=gift.provinceId
        self.cityId=gift.cityId
        self.regionId=gift.regionId

        self.isReviewed = false
    }
    
    
    final class Input : Codable {
        var title:String
        var description:String
        var price:String
        var categoryId:Int
        var giftImages:[String]
        var isNew:Bool
        var provinceId:Int
        var cityId:Int
        var regionId:Int?
    }
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
    
    static func getGiftsWithRequestFilter(query:QueryBuilder<PostgreSQLDatabase, Gift>,requestInput:RequestInput?,onlyUndonatedGifts:Bool,onlyReviewedGifts:Bool)->Future<[Gift]>{
        
        if let searchWord = requestInput?.searchWord {
            query.group(.or) { query in
                query
                    .filter(\.title ~~ searchWord)
                    .filter(\.description ~~ searchWord)
            }
        }
        
        if let categoryId = requestInput?.categoryId {
            query.filter(\.categoryId == categoryId)
        }
        
        if let cityId = requestInput?.cityId {
            query.filter(\.cityId == cityId)
        } else {
            if let provinceId = requestInput?.provinceId {
                query.filter(\.provinceId == provinceId)
            }
        }
        
        if let beforeId = requestInput?.beforeId {
            query.filter(\.id < beforeId)
        }
        
        if onlyUndonatedGifts {
            query.filter(\.donatedToUserId == nil)
        }
        
        if onlyReviewedGifts {
            query.filter(\.isReviewed == true)
        }
        
        let maximumCount = Constants.maximumRequestFetchResultsCount
        var count = requestInput?.count ?? maximumCount
        if count > maximumCount {
            count = maximumCount
        }
        
        return query.sort(\.id, .descending).range(0..<count).all()
    }
    
    
}

/// Allows `Gift` to be used as a dynamic migration.
extension Gift : Migration {}

/// Allows `Gift` to be encoded to and decoded from HTTP messages.
extension Gift : Content {}

/// Allows `Gift` to be used as a dynamic parameter in route definitions.
extension Gift : Parameter {}
