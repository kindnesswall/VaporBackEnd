//
//  PhoneNumberActivationCode.swift
//  App
//
//  Created by Amir Hossein on 3/31/20.
//

import Vapor
import FluentPostgreSQL

final class PhoneNumberActivationCode: PostgreSQLModel {
    var id:Int?
    var phoneNumber:String
    var activationCode:String?
    
    init(phoneNumber:String, activationCode:String?) {
        self.phoneNumber = phoneNumber
        self.activationCode = activationCode
    }
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
}

extension PhoneNumberActivationCode {
    
    static func find(req: Request, phoneNumber: String) -> Future<PhoneNumberActivationCode?> {
        
        return PhoneNumberActivationCode.query(on: req).filter(\.phoneNumber == phoneNumber).first()
        
    }
    
    static func check(req: Request, phoneNumber: String, activationCode: String) -> Future<HTTPStatus> {
        
        return PhoneNumberActivationCode.query(on: req).filter(\.phoneNumber == phoneNumber).filter(\.activationCode == activationCode).first().flatMap { item in
            guard let item = item else {
                throw Abort(.invalidActivationCode)
            }
            item.activationCode = nil
            return item.save(on: req).transform(to: .ok)
        }
    }
}

extension PhoneNumberActivationCode {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension PhoneNumberActivationCode : Migration {}

extension PhoneNumberActivationCode : Content {}

extension PhoneNumberActivationCode : Parameter {}
