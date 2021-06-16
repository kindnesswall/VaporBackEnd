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
    var isReviewed:Bool
    
    @Field(key: "isRejected")
    var isRejected:Bool
    
    @Field(key: "isDeleted")
    var isDeleted:Bool
    
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
        guard let userId = self.$user.id else {
            throw Abort(.nilGiftUserId)
        }
        return userId
    }
    
    private init(input: Gift.Input, authId: Int) {
        self.$user.id = authId
        self.isRejected = false
        self.isDeleted = false
        self.isReviewed = false
        
        self.title=input.title
        self.description=input.description
        self.price=input.price
        self.$category.id=input.categoryId
        self.giftImages=input.giftImages
        self.isNew=input.isNew
        self.countryId=input.countryId
        self.$province.id=input.provinceId
        self.$city.id=input.cityId
        self.$region.id=input.regionId
    }
    
    private func update(input: Gift.Input) {
        
        self.title=input.title
        self.description=input.description
        self.price=input.price
        self.$category.id=input.categoryId
        self.giftImages=input.giftImages
        self.isNew=input.isNew
        self.countryId=input.countryId
        self.$province.id=input.provinceId
        self.$city.id=input.cityId
        self.$region.id=input.regionId

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
        return $donatedToUser.id != nil
    }
}

extension Gift {
    
    static func create(input: Gift.Input, authId: Int, on req: Request) -> EventLoopFuture<Gift> {
        let gift = Gift(input: input, authId: authId)
        return gift.setNamesAndSave(on: req)
    }
    
    func update(input: Gift.Input, authId: Int, on req: Request) throws -> EventLoopFuture<Gift> {
        
        guard self.$user.id == authId else { throw Abort(.unauthorizedGift) }
        guard !self.isDeleted else { throw Abort(.deletedGift) }
        guard !isDonated else { throw Abort(.donatedGiftUnaccepted) }
        
        return self.restore(on: req.db).flatMap {
            self.update(input: input)
            return self.setNamesAndSave(on: req)
        }
    }
}

extension Gift {
    private func setNamesAndSave(on req: Request) ->  EventLoopFuture<Gift> {
        return getCountry(on: req).flatMap { country in
            self.countryName = country.name
            
            return self.getCategoryTitle(on: req, country: country).flatMap { categoryTitle in
                self.categoryTitle = categoryTitle
                
                return self.$province.get(on: req.db).flatMap { province in
                    self.provinceName = province.name
                    
                    return self.$city.get(on: req.db).flatMap { city in
                        self.cityName = city.name
                        
                        if self.$region.id != nil {
                            return self.$region.get(on: req.db).flatMap { region in
                                self.regionName = region?.name
                                return self.save(on: req.db).transform(to: self)
                            }
                        } else {
                            self.regionName = nil
                            return self.save(on: req.db).transform(to: self)
                        }
                    }
                }
            }
        }
    }
}

extension Gift {
    func getCountry(on req: Request) -> EventLoopFuture<Country>  {
        guard let countryId = self.countryId else {
            return req.db.makeFailedFuture(.nilCountryId)
        }
        return Country
            .find(countryId, on: req.db)
            .unwrap(or: Abort(.countryNotFound))
    }
    
    func getCategoryTitle(on req: Request, country: Country) -> EventLoopFuture<String?> {
        return $category.get(on: req.db).map { category in
            return category.localizedTitle(country: country)
        }
    }
}

extension Gift {
    
    static func getGiftsWithRequestFilter(query:QueryBuilder<Gift>,requestInput:RequestInput?,onlyUndonatedGifts:Bool,onlyReviewedGifts:Bool)->EventLoopFuture<[Gift]>{
        
        if let searchWord = requestInput?.searchWord {
            query.group(.or) { query in
                query
                    .filter(\.$title ~~ searchWord)
                    .filter(\.$description ~~ searchWord)
            }
        }
        
        if let categoryIds = requestInput?.categoryIds {
            query.group(.or) { query in
                for categoryId in categoryIds {
                    query.filter(\.$category.$id == categoryId)
                }
            }
        }
        
        if let regionIds = requestInput?.regionIds {
            query.group(.or) { query in
                for regionId in regionIds {
                    query.filter(\.$region.$id == regionId)
                }
            }
        } else {
            if let cityId = requestInput?.cityId {
                query.filter(\.$city.$id == cityId)
            } else {
                if let provinceId = requestInput?.provinceId {
                    query.filter(\.$province.$id == provinceId)
                } else {
                    if let countryId = requestInput?.countryId {
                        query.filter(\.$countryId == countryId)
                    }
                }
            }
        }
        
        if let beforeId = requestInput?.beforeId {
            query.filter(\.$id < beforeId)
        }
        
        if onlyUndonatedGifts {
            query.filter(\.$donatedToUser.$id == nil)
        }
        
        if onlyReviewedGifts {
            query.filter(\.$isReviewed == true)
        }
        
        let count = Constants.maxFetchCount(bound: requestInput?.count)
        
        return query.sort(\.$id, .descending).range(0..<count).all()
    }
    
    
}

/// Allows `Gift` to be used as a dynamic migration.
//extension Gift : Migration {}

/// Allows `Gift` to be encoded to and decoded from HTTP messages.
extension Gift : Content {}

