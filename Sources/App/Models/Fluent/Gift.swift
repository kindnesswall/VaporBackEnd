//
//  Gift.swift
//  App
//
//  Created by Amir Hossein on 1/10/19.
//

import Vapor
import Fluent
import FluentSQL

final class Gift : Model {
    
    static let schema = "Gift"
    
    @ID(key: .id)
    var id:Int?
    
    @OptionalParent(key: "userId")
    var user: User?
    
    @OptionalParent(key: "donatedToUserId")
    var donatedToUser: User?
    
    @Parent(key: "categoryId")
    var category: Category
    
    @Field(key: "isReviewed")
    var isReviewed = false
    
    @Field(key: "isRejected")
    var isRejected = false
    
    @Field(key: "isDeleted")
    var isDeleted = false
    
    @OptionalField(key: "rejectReason")
    var rejectReason: String?
    
    @OptionalField(key: "categoryTitle")
    var categoryTitle:String?
    
    @OptionalField(key: "countryName")
    var countryName: String?
    
    @OptionalField(key: "provinceName")
    var provinceName:String?
    
    @OptionalField(key: "cityName")
    var cityName:String?
    
    @OptionalField(key: "regionName")
    var regionName:String?
    
    @Field(key: "title")
    var title:String
    
    @Field(key: "description")
    var description:String
    
    @Field(key: "price")
    var price:Double
    
    @Field(key: "giftImages")
    var giftImages:[String]
    
    @Field(key: "isNew")
    var isNew:Bool
    
    @OptionalField(key: "countryId")
    var countryId: Int?
    
    @Parent(key: "provinceId")
    var province: Province
    
    @Parent(key: "cityId")
    var city: City
    
    @OptionalParent(key: "regionId")
    var region: Region?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
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
    var isDonated: Bool {
        return donatedToUserId != nil
    }
}

extension Gift {
    
    static func create(input: Gift.Input, authId: Int, on req: Request) throws -> EventLoopFuture<Gift> {
        let gift = Gift(input: input, authId: authId)
        return try gift.setNamesAndSave(on: req)
    }
    
    func update(input: Gift.Input, authId: Int, on req: Request) throws -> EventLoopFuture<Gift> {
        
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
    private func setNamesAndSave(on req: Request) throws ->  EventLoopFuture<Gift> {
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
    
    static func get(_ id: Int, on conn: Database) -> EventLoopFuture<Gift> {
        return find(id, on: conn).unwrap(or: Abort(.giftNotFound))
    }
    
    static func get(_ id: Int, withSoftDeleted: Bool, on conn: Database) -> EventLoopFuture<Gift> {
        return query(on: conn, withSoftDeleted: withSoftDeleted).filter(\.id == id).first().unwrap(or: Abort(.giftNotFound))
    }
}

extension Gift {
    func getCountry(on req: Request) throws -> EventLoopFuture<Country>  {
        guard let countryId = self.countryId else {
            throw Abort(.nilCountryId)
        }
        return Country.find(countryId, on: req).unwrap(or: Abort(.countryNotFound))
    }
    
    func getCategoryTitle(on req: Request, country: Country) -> EventLoopFuture<String?> {
        return category.get(on: req).map { category in
            return category.localizedTitle(country: country)
        }
    }
}

extension Gift {
    
    static func getGiftsWithRequestFilter(query:QueryBuilder<PostgreSQLDatabase, Gift>,requestInput:RequestInput?,onlyUndonatedGifts:Bool,onlyReviewedGifts:Bool)->EventLoopFuture<[Gift]>{
        
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
//extension Gift : Migration {}

/// Allows `Gift` to be encoded to and decoded from HTTP messages.
extension Gift : Content {}

