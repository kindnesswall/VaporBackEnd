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
    
    @OptionalField(key: "previousCopyId")
    var previousCopyId: Int?
    
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
    
    private init(input: Gift.Input, authId: Int, previousCopyId: Int?) {
        self.$user.id = authId
        self.previousCopyId = previousCopyId
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
    var isAcceptedByReviewer: Bool { isReviewed && !isRejected }
}

extension Gift {
    
    static func create(input: Gift.Input, authId: Int, previousCopyId: Int? = nil, on req: Request) -> EventLoopFuture<Gift> {
        let gift = Gift(input: input, authId: authId, previousCopyId: previousCopyId)
        return gift.setNamesAndSave(on: req)
    }
    
    func update(input: Gift.Input, authId: Int, on req: Request) -> EventLoopFuture<Gift> {
        
        guard $user.id == authId else { return req.db.makeFailedFuture(.unauthorizedGift) }
        guard !isDeleted else { return req.db.makeFailedFuture(.deletedGift) }
        guard !isDonated else { return req.db.makeFailedFuture(.donatedGiftUnaccepted) }
        
        //TODO: Previous reject reason may be helpful for the next review
        
        return delete(authId: authId, on: req.db).flatMap {
            return Self.create(
                input: input,
                authId: authId,
                previousCopyId: self.id,
                on: req)
        }
    }
    
    func delete(authId: Int, on db: Database) -> EventLoopFuture<Void> {
        
        guard $user.id == authId else { return db.makeFailedFuture(.unauthorizedGift) }
        guard !isDonated else { return db.makeFailedFuture(.donatedGiftUnaccepted) }
        
        if deletedAt == nil {
            isDeleted = true
            return update(on: db).flatMap {
                return self.delete(on: db)
            }
        } else {
            return db.transaction { db in
                return self.restore(on: db).flatMap {
                    self.isDeleted = true
                    return self.update(on: db).flatMap {
                        return self.delete(on: db)
                    }
                }
            }
        }
    }
}

extension Gift {
    
    func wasReceived(by userId: Int, on db: Database) throws -> EventLoopFuture<HTTPStatus> {
        guard isAcceptedByReviewer
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
    
    static func filterGifts(
        giftQuery: GiftQuery
    ) {
        filterGifts(
            query: giftQuery.query,
            requestInput: giftQuery.requestInput,
            onlyReviewerAcceptedGifts: giftQuery.onlyReviewerAcceptedGifts)
    }
    
    static func filterGifts(
        query: QueryBuilder<Gift>,
        requestInput: RequestInput,
        onlyReviewerAcceptedGifts: Bool
    ) {
        if let searchWord = requestInput.searchWord {
            query.group(.or) { query in
                query
                    .filter(\.$title ~~ searchWord)
                    .filter(\.$description ~~ searchWord)
            }
        }
        
        if let categoryIds = requestInput.categoryIds {
            query.group(.or) { query in
                for categoryId in categoryIds {
                    query.filter(\.$category.$id == categoryId)
                }
            }
        }
        
        if let regionIds = requestInput.regionIds {
            query.group(.or) { query in
                for regionId in regionIds {
                    query.filter(\.$region.$id == regionId)
                }
            }
        } else {
            if let cityId = requestInput.cityId {
                query.filter(\.$city.$id == cityId)
            } else {
                if let provinceId = requestInput.provinceId {
                    query.filter(\.$province.$id == provinceId)
                } else {
                    if let countryId = requestInput.countryId {
                        query.filter(\.$countryId == countryId)
                    }
                }
            }
        }
        
        if let isDonated = requestInput.isDonated {
            if isDonated {
                query.filter(\.$donatedToUser.$id != nil)
            } else {
                query.filter(\.$donatedToUser.$id == nil)
            }
        }
        
        if let isDelivered = requestInput.isDelivered {
            if isDelivered {
                query.filter(\.$isDelivered == true)
            } else {
                query.filter(\.$isDelivered != true)
            }
        }
        
        if onlyReviewerAcceptedGifts {
            query
                .filter(\.$isReviewed == true)
                .filter(\.$isRejected == false)
        }
    }
    
    static func getGifts(
        giftQuery: GiftQuery
    ) -> EventLoopFuture<[Gift.Output]> {
        
        filterGifts(giftQuery: giftQuery)
        let query = giftQuery.query
        let count = giftQuery.requestInput.getCount()
        let beforeId = giftQuery.requestInput.beforeId
        
        if let beforeId = beforeId {
            query.filter(\.$id < beforeId)
        }
        return query
            .sort(\.$id, .descending)
            .range(0..<count)
            .all()
            .outputArray
    }
    
    static func getPaginatedGifts(
        giftQuery: GiftQuery
    ) -> EventLoopFuture<Page<Gift.Output>> {
        
        filterGifts(giftQuery: giftQuery)
        let query = giftQuery.query
        let count = giftQuery.requestInput.getCount()
        let page = giftQuery.requestInput.page ?? 1
        
        return query
            .paginate(PageRequest(page: page, per: count))
            .outputPage
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

extension EventLoopFuture where Value == Page<Gift> {
    var outputPage: EventLoopFuture<Page<Gift.Output>> {
        map { $0.map { $0.outputObject } }
    }
}
