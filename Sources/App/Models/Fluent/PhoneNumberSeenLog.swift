//
//  PhoneNumberSeenLog.swift
//  App
//
//  Created by Amir Hossein on 5/5/21.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class PhoneNumberSeenLog: PostgreSQLModel {
    
    var id: Int?
    var fromUserId: Int
    var seenUserId: Int
    var seenPhoneNumber: String
    
    var createdAt: Date?
    
    
    init(fromUserId: Int, seenUserId: Int, seenPhoneNumber: String) {
        self.fromUserId = fromUserId
        self.seenUserId = seenUserId
        self.seenPhoneNumber = seenPhoneNumber
    }
}

extension PhoneNumberSeenLog {
    static let createdAtKey: TimestampKey? = \.createdAt
}

extension PhoneNumberSeenLog : Migration {}

extension PhoneNumberSeenLog : Content {}

extension PhoneNumberSeenLog : Parameter {}

