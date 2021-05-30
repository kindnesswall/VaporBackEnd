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
    
    @ID(key: .id)
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
    
    init() {}
    
    init(phoneNumber:String, activationCode:String?) {
        self.phoneNumber = phoneNumber
        self.activationCode = activationCode
    }
    
}

extension PhoneNumberActivationCode {
    
    static func find(req: Request, phoneNumber: String) -> EventLoopFuture<PhoneNumberActivationCode?> {
        
        return PhoneNumberActivationCode.query(on: req.db).filter(\.$phoneNumber == phoneNumber).first()
        
    }
    
    static func check(req: Request, phoneNumber: String, activationCode: String) -> EventLoopFuture<HTTPStatus> {
        
        return PhoneNumberActivationCode.query(on: req.db).filter(\.$phoneNumber == phoneNumber).filter(\.$activationCode == activationCode).first().flatMap { item in
            guard let item = item else {
                throw Abort(.invalidActivationCode)
            }
            item.activationCode = nil
            return item.save(on: req).transform(to: .ok)
        }
    }
}

//extension PhoneNumberActivationCode : Migration {}

extension PhoneNumberActivationCode : Content {}


