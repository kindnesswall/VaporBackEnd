//
//  Gift.swift
//  App
//
//  Created by Amir Hossein on 1/10/19.
//

import Vapor
import Fluent
import FluentPostgresDriver
import FluentSQL

final class Gift : PostgreSQLModel {
    var id:Int?
    var userId:Int?
    var donatedToUserId:Int?
    var isReviewed = false
    var isRejected = false
    var isDeleted = false
    var rejectReason: String?
    var categoryTitle:String?
    var countryName: String?
    var provinceName:String?
    var cityName:String?
    var regionName:String?
    
    var title:String
    var description:String
    var price:Double
    var categoryId:Int
    var giftImages:[String]
    var isNew:Bool
    var countryId: Int?
    var provinceId:Int
    var cityId:Int
    var regionId:Int?
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    func getId() throws -> Int {
        guard let id = self.id else {
            throw Abort(.nilGiftId)
        }
        return id
    }
    
    func getUserId() throws -> Int {
        guard let userId = self.userId else {
            throw Abort(.nilGiftUserId)
        }
        return userId
    }
    
    private init(input: Gift.Input, authId: Int) {
        self.userId = authId
        
        self.title=input.title
        self.description=input.description
        self.price=input.price
        self.categoryId=input.categoryId
        self.giftImages=input.giftImages
        self.isNew=input.isNew
        self.countryId=input.countryId
        self.provinceId=input.provinceId
        self.cityId=input.cityId
        self.regionId=input.regionId
    }
    
    private func update(input: Gift.Input) throws {
        
        self.title=input.title
        self.description=input.description
        self.price=input.price
        self.categoryId=input.categoryId
        self.giftImages=input.giftImages
        self.isNew=input.isNew
        self.countryId=input.countryId
        self.provinceId=input.provinceId
        self.cityId=input.cityId
        self.regionId=input.regionId

        self.isRejected = false
//        self.rejectReason = nil // Note: Commented because the reason may help for the next review
        self.isReviewed = false
    }
    
    
    final class Input : Codable {
        var title:String
        var description:String
        var price:Double
        var categoryId:Int
        var giftImages:[String]
        var isNew:Bool
        var countryId: Int
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
    var province : Parent<Gift, Province> {
        return parent(\.provinceId)
    }
    var city : Parent<Gift, City> {
        return parent(\.cityId)
    }
    var region : Parent<Gift, Region>? {
        return parent(\.regionId)
    }
}

extension Gift {
    var isDonated: Bool {
        return donatedToUserId != nil
    }
}

extension Gift {
    
    static func create(input: Gift.Input, authId: Int, on req: Request) throws -> Future<Gift> {
        let gift = Gift(input: input, authId: authId)
        return try gift.setNamesAndSave(on: req)
    }
    
    func update(input: Gift.Input, authId: Int, on req: Request) throws -> Future<Gift> {
        
        guard self.userId == authId else { throw Abort(.unauthorizedGift) }
        guard !self.isDeleted else { throw Abort(.deletedGift) }
        guard !isDonated else { throw Abort(.donatedGiftUnaccepted) }
        
        return self.restore(on: req).flatMap { gift in
            try gift.update(input: input)
            return try gift.setNamesAndSave(on: req)
        }
    }
}

extension Gift {
    private func setNamesAndSave(on req: Request) throws ->  Future<Gift> {
        return try getCountry(on: req).flatMap { country in
            self.countryName = country.name
            
            return self.getCategoryTitle(on: req, country: country).flatMap { categoryTitle in
                self.categoryTitle = categoryTitle
                
                return self.province.get(on: req).flatMap { province in
                    self.provinceName = province.name
                    
                    return self.city.get(on: req).flatMap { city in
                        self.cityName = city.name
                        
                        if let region = self.region {
                            return region.get(on: req).flatMap { region in
                                self.regionName = region.name
                                return self.save(on: req)
                            }
                        } else {
                            self.regionName = nil
                            return self.save(on: req)
                        }
                    }
                }
            }
        }
    }
}

extension Gift {
    
    static func get(_ id: Int, on conn: DatabaseConnectable) -> Future<Gift> {
        return find(id, on: conn).unwrap(or: Abort(.giftNotFound))
    }
    
    static func get(_ id: Int, withSoftDeleted: Bool, on conn: DatabaseConnectable) -> Future<Gift> {
        return query(on: conn, withSoftDeleted: withSoftDeleted).filter(\.id == id).first().unwrap(or: Abort(.giftNotFound))
    }
}

extension Gift {
    func getCountry(on req: Request) throws -> Future<Country>  {
        guard let countryId = self.countryId else {
            throw Abort(.nilCountryId)
        }
        return Country.find(countryId, on: req).unwrap(or: Abort(.countryNotFound))
    }
    
    func getCategoryTitle(on req: Request, country: Country) -> Future<String?> {
        return category.get(on: req).map { category in
            return category.localizedTitle(country: country)
        }
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
        
        if let categoryIds = requestInput?.categoryIds {
            query.group(.or) { query in
                for categoryId in categoryIds {
                    query.filter(\.categoryId == categoryId)
                }
            }
        }
        
        if let regionIds = requestInput?.regionIds {
            query.group(.or) { query in
                for regionId in regionIds {
                    query.filter(\.regionId == regionId)
                }
            }
        } else {
            if let cityId = requestInput?.cityId {
                query.filter(\.cityId == cityId)
            } else {
                if let provinceId = requestInput?.provinceId {
                    query.filter(\.provinceId == provinceId)
                } else {
                    if let countryId = requestInput?.countryId {
                        query.filter(\.countryId == countryId)
                    }
                }
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
        
        let count = Constants.maxFetchCount(bound: requestInput?.count)
        
        return query.sort(\.id, .descending).range(0..<count).all()
    }
    
    
}

/// Allows `Gift` to be used as a dynamic migration.
extension Gift : Migration {}

/// Allows `Gift` to be encoded to and decoded from HTTP messages.
extension Gift : Content {}

/// Allows `Gift` to be used as a dynamic parameter in route definitions.
extension Gift : Parameter {}
