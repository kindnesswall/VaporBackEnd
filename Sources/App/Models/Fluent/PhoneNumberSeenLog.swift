//
//  PhoneNumberSeenLog.swift
//  App
//
//  Created by Amir Hossein on 5/5/21.
//

import Vapor
import Fluent

final class PhoneNumberSeenLog: Model {
    
    static let schema = "PhoneNumberSeenLog"
    
    var id: Int?
    var fromUserId: Int
    var seenUserId: Int
    var seenPhoneNumber: String
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(fromUserId: Int, seenUserId: Int, seenPhoneNumber: String) {
        self.fromUserId = fromUserId
        self.seenUserId = seenUserId
        self.seenPhoneNumber = seenPhoneNumber
    }
}

//extension PhoneNumberSeenLog : Migration {}

extension PhoneNumberSeenLog : Content {}



