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
    
    @ID(custom: .id)
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
    
    @OptionalField(key: "isDelivered")
    var isDelivered: Bool?
    
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
    
    var outputObject: Output {
        .init(
            id: id,
            userId: $user.id,
            donatedToUserId: $donatedToUser.id,
            isReviewed: isReviewed,
            isRejected: isRejected,
            isDeleted: isDeleted,
            rejectReason: rejectReason,
            categoryTitle: categoryTitle,
            countryName: countryName,
            provinceName: provinceName,
            cityName: cityName,
            regionName: regionName,
            title: title,
            description: description,
            price: price,
            categoryId: $category.id,
            giftImages: giftImages,
            isNew: isNew,
            countryId: countryId,
            provinceId: $province.id,
            cityId: $city.id,
            regionId: $region.id,
            isDelivered: isDelivered,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt)
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
    
    struct Output: Content {
        let id:Int?
        let userId:Int?
        let donatedToUserId:Int?
        let isReviewed: Bool
        let isRejected: Bool
        let isDeleted: Bool
        let rejectReason: String?
        let categoryTitle:String?
        let countryName: String?
        let provinceName:String?
        let cityName:String?
        let regionName:String?
        
        let title:String
        let description:String
        let price:Double
        let categoryId:Int
        let giftImages:[String]
        let isNew:Bool
        let countryId: Int?
        let provinceId:Int
        let cityId:Int
        let regionId:Int?
        let isDelivered: Bool?
        
        let createdAt: Date?
        let updatedAt: Date?
        let deletedAt: Date?
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
        
        guard $user.id == authId else { throw Abort(.unauthorizedGift) }
        guard !self.isDeleted else { throw Abort(.deletedGift) }
        guard !isDonated else { throw Abort(.donatedGiftUnaccepted) }
        
        //TODO: Restore it only when it is deleted.
        return self.restore(on: req.db).flatMap {
            self.update(input: input)
            return self.setNamesAndSave(on: req)
        }
    }
    
    func delete(authId: Int, on db: Database) throws -> EventLoopFuture<HTTPStatus> {
        
        guard $user.id == authId else { throw Abort(.unauthorizedGift) }
        guard !isDonated else { throw Abort(.donatedGiftUnaccepted) }
        isDeleted = true
        return save(on: db).flatMap {
            return self.delete(on: db)
                .transform(to: .ok)
        }
        
    }
}

extension Gift {
    
    func wasReceived(by userId: Int, on db: Database) throws -> EventLoopFuture<HTTPStatus> {
        guard isReviewed == true
        else { throw Abort(.unreviewedGift) }
        
        guard $donatedToUser.id == nil
        else { throw Abort(.giftIsAlreadyDonated) }
        
        $donatedToUser.id = userId
        return save(on: db)
            .transform(to: .ok)
    }
    
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
    
    static func getGiftsWithRequestFilter(query:QueryBuilder<Gift>,requestInput:RequestInput?, onlyReviewedGifts:Bool)->EventLoopFuture<[Gift]>{
        
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
        
        if let isDonated = requestInput?.isDonated {
            if isDonated {
                query.filter(\.$donatedToUser.$id != nil)
            } else {
                query.filter(\.$donatedToUser.$id == nil)
            }
        }
        
        if let isDelivered = requestInput?.isDelivered {
            if isDelivered {
                query.filter(\.$isDelivered == true)
            } else {
                query.filter(\.$isDelivered != true)
            }
        }
        
        if let beforeId = requestInput?.beforeId {
            query.filter(\.$id < beforeId)
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

extension Array where Element == Gift {
    var outputArray: [Gift.Output] {
        map { $0.outputObject }
    }
}

extension EventLoopFuture where Value == Gift {
    var outputObject: EventLoopFuture<Gift.Output> {
        map { $0.outputObject }
    }
}

extension EventLoopFuture where Value == [Gift] {
    var outputArray: EventLoopFuture<[Gift.Output]> {
        map { $0.outputArray }
    }
}
