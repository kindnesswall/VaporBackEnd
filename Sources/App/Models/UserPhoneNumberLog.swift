//
//  UserPhoneNumberLog.swift
//  App
//
//  Created by Amir Hossein on 9/20/19.
//

import Vapor
import FluentPostgreSQL

final class UserPhoneNumberLog: PostgreSQLModel {
    var id:Int?
    var userId:Int
    var fromPhoneNumber:String
    var toPhoneNumber:String
    var status:String
    var activationCode:String?
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    init(userId: Int, fromPhoneNumber: String, toPhoneNumber: String, status: ChangeStatus) {
        
        self.userId = userId
        self.fromPhoneNumber = fromPhoneNumber
        self.toPhoneNumber = toPhoneNumber
        self.status = status.rawValue
        
    }
    
    func setStatus(status: ChangeStatus) {
        self.status = status.rawValue
    }
    
    enum ChangeStatus: String {
        case requested
        case completed
    }
}

extension UserPhoneNumberLog {
    static func getLast(phoneNumberLog: UserPhoneNumberLog, conn:DatabaseConnectable) -> Future<UserPhoneNumberLog?> {
        return UserPhoneNumberLog.query(on: conn)
            .filter(\.userId == phoneNumberLog.userId)
            .filter(\.fromPhoneNumber == phoneNumberLog.fromPhoneNumber)
            .filter(\.toPhoneNumber == phoneNumberLog.toPhoneNumber)
            .filter(\.status == phoneNumberLog.status)
        .sort(\.createdAt, .descending).first()
    }
}

extension UserPhoneNumberLog {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension UserPhoneNumberLog : Migration {}

extension UserPhoneNumberLog : Content {}

extension UserPhoneNumberLog : Parameter {}
