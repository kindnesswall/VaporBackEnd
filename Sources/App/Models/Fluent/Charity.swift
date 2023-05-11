//
//  Charity.swift
//  app
//
//  Created by Hamed Ghadirian on 10.07.19.
//  Copyright © 2019 Hamed.Gh. All rights reserved.
//

import Vapor
import Fluent

final class Charity: Model {
    
    static let schema = "Charity"
    
    @ID(custom: .id)
    var id: Int?
    
    @OptionalField(key: "userId")
    var userId:Int?
    
    @OptionalField(key: "isRejected")
    var isRejected:Bool?
    
    @OptionalField(key: "rejectReason")
    var rejectReason: String?
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "images")
    var images: [String]?
    
    @OptionalField(key: "logoImage")
    var logoImage: String?
    
    @OptionalField(key: "countryId")
    var countryId: Int?
    
    @OptionalField(key: "provinceId")
    var provinceId: Int?
    
    @OptionalField(key: "cityId")
    var cityId: Int?
    
    @OptionalField(key: "countryName")
    var countryName: String?
    
    @OptionalField(key: "provinceName")
    var provinceName:String?
    
    @OptionalField(key: "cityName")
    var cityName:String?
    
    @OptionalField(key: "address")
    var address: String?
    
    @OptionalField(key: "telephoneNumber")
    var telephoneNumber: String?
    
    @OptionalField(key: "mobileNumber")
    var mobileNumber: String?
    
    @OptionalField(key: "website")
    var website: String?
    
    @OptionalField(key: "email")
    var email: String?
    
    @OptionalField(key: "instagram")
    var instagram: String?
    
    @OptionalField(key: "telegram")
    var telegram: String?
    
    @OptionalField(key: "whatsApp")
    var whatsApp: String?
    
    @OptionalField(key: "managerName")
    var managerName: String?
    
    @OptionalField(key: "licenseId")
    var licenseId: String?
    
    @OptionalField(key: "licenseDate")
    var licenseDate: Date?
    
    @OptionalField(key: "institutionIssuedLicense")
    var institutionIssuedLicense: String?
    
    @OptionalField(key: "licenseImages")
    var licenseImages: [String]?
    
    @OptionalField(key: "bankAccountNumber")
    var bankAccountNumber: String?
    
    @OptionalField(key: "bankName")
    var bankName: String?
    
    @OptionalField(key: "bankAccountOwner")
    var bankAccountOwner: String?
    
    @OptionalField(key: "description")
    var description: String?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(userId: Int) {
        self.userId = userId
        self.name = ""
    }
    
    func set(_ input: Input) {
        self.name = input.name
        self.images = input.images
        self.logoImage = input.logoImage
        self.countryId = input.countryId
        self.provinceId = input.provinceId
        self.cityId = input.cityId
        self.address = input.address
        self.telephoneNumber = input.telephoneNumber
        self.mobileNumber = input.mobileNumber
        self.website = input.website
        self.email = input.email
        self.instagram = input.instagram
        self.telegram = input.telegram
        self.whatsApp = input.whatsApp
        self.managerName = input.managerName
        self.licenseId = input.licenseId
        self.institutionIssuedLicense = input.institutionIssuedLicense
        self.licenseImages = input.licenseImages
        self.bankAccountNumber = input.bankAccountNumber
        self.bankName = input.bankName
        self.bankAccountOwner = input.bankAccountOwner
        self.description = input.description
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.licenseDate = formatter.date(from: input.licenseDate ?? "")
    }
    
    static func create(userId: Int, _ input: Input, on db: Database) -> EventLoopFuture<Charity> {
        let object = Charity(userId: userId)
        object.set(input)
        
        object.isRejected = false
        
        return object.setNames(on: db)
            .flatMap {
                object.create(on: db)
                    .transform(to: object)
            }
    }
    
    func update(_ input: Input, on db: Database) -> EventLoopFuture<Void> {
        set(input)
        
        self.isRejected = false
//        self.rejectReason = nil // Note: Commented because the reason may be helpful for the next review
        
        return self.setNames(on: db)
            .flatMap {
                self.update(on: db)
            }
    }
    
    
    final class Input : Codable {
        var name: String
        var images: [String]?
        var logoImage: String?
        var countryId: Int
        var provinceId: Int
        var cityId: Int
        var address: String?
        var telephoneNumber: String?
        var mobileNumber: String?
        var website: String?
        var email: String?
        var instagram: String?
        var telegram: String?
        var whatsApp: String?
        var managerName: String?
        var licenseId: String?
        var licenseDate: String?
        var institutionIssuedLicense: String?
        var licenseImages: [String]?
        var bankAccountNumber: String?
        var bankName: String?
        var bankAccountOwner: String?
        var description: String?
    }
}

extension Charity {
    
    private func setNames(on db: Database) -> EventLoopFuture<Void> {
        Country
            .find(countryId, on: db)
            .unwrap(or: Abort(.countryNotFound))
            .flatMap { country in
                self.countryName = country.name
                return Province
                    .find(self.provinceId, on: db)
                    .unwrap(or: Abort(.provinceNotFound))
                    .flatMap { province in
                        self.provinceName = province.name
                        return City
                            .find(self.cityId, on: db)
                            .unwrap(or: Abort(.cityNotFound))
                            .map { city in
                                self.cityName = city.name
                            }
                    }
            }
    }
    
    static func getAllCharities(conn:Database) -> EventLoopFuture<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.$deletedAt == nil) //TODO: Is it needed?
            .join(User.self, on: \Charity.$userId == \User.$id)
            .filter(User.self, \.$isCharity == true)
            .all()
    }
    
    static func getCharityReviewList(conn:Database) -> EventLoopFuture<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.$isRejected == false)
            .join(User.self, on: \Charity.$userId == \User.$id)
            .filter(User.self, \.$deletedAt == nil)
            .filter(User.self, \.$isCharity == false)
            .all()
    }
    
    static func getCharityRejectedList(conn:Database) -> EventLoopFuture<[Charity]> {
        return Charity.query(on: conn)
            .filter(\.$isRejected == true)
            .join(User.self, on: \Charity.$userId == \User.$id)
            .filter(User.self, \.$deletedAt == nil)
            .all()
    }
}

extension Charity {
    static func find(userId: Int, on conn: Database) -> EventLoopFuture<Charity?> {
        return Charity.query(on: conn).filter(\.$userId == userId).first()
    }
    
    static func hasFound(userId: Int, on conn: Database) -> EventLoopFuture<Bool> {
        return find(userId: userId, on: conn).map { $0 != nil }
    }
    
    static func get(userId: Int , on conn: Database) -> EventLoopFuture<Charity> {
        return find(userId: userId, on: conn).unwrap(or: Abort(.charityInfoNotFound))
    }
}

//extension Charity : Migration {}

extension Charity : Content {}
