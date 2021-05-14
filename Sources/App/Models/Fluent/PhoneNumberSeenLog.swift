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
    
    @ID(key: .id)
    var id: Int?
    
    @Field(key: "fromUserId")
    var fromUserId: Int
    
    @Field(key: "seenUserId")
    var seenUserId: Int
    
    @Field(key: "seenPhoneNumber")
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



