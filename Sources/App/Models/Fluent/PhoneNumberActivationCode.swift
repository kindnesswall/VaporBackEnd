//
//  PhoneNumberActivationCode.swift
//  App
//
//  Created by Amir Hossein on 3/31/20.
//

import Vapor
import Fluent

final class PhoneNumberActivationCode: Model {
    
    static let schema = "PhoneNumberActivationCode"
    
    @ID(custom: .id)
    var id:Int?
    
    @Field(key: "phoneNumber")
    var phoneNumber:String
    
    @OptionalField(key: "activationCode")
    var activationCode:String?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    @Timestamp(key: "activationCodeExpiresAt", on: .none)
    var activationCodeExpiresAt: Date?
    
    init() {}
    
    init(phoneNumber:String, activationCode:String?) {
        self.phoneNumber = phoneNumber
        self.set(activationCode: activationCode)
    }
    
    func set(activationCode: String?) {
        self.activationCode = activationCode
        self.activationCodeExpiresAt = Date().addingTimeInterval(60 * 2)
    }
    
}

extension PhoneNumberActivationCode {
    
    static func find(req: Request, phoneNumber: String) -> EventLoopFuture<PhoneNumberActivationCode?> {
        return query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .first()
        
    }
    
    static func check(req: Request, phoneNumber: String, activationCode: String) -> EventLoopFuture<HTTPStatus> {
        return query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .filter(\.$activationCode == activationCode)
            .first()
            .flatMap { item in
                guard let item = item else {
                    return req.db.makeFailedFuture(.invalidActivationCode)
                }
                guard
                    let expiresAt = item.activationCodeExpiresAt,
                    expiresAt > Date() else {
                    return req.db.makeFailedFuture(.expiredActivationCode)
                }
                item.activationCode = nil
                return item
                    .save(on: req.db)
                    .transform(to: .ok)
            }
    }
}

//extension PhoneNumberActivationCode : Migration {}

extension PhoneNumberActivationCode : Content {}


