//
//  CharityLog.swift
//  
//
//  Created by AmirHossein on 1/17/23.
//

import Vapor
import Fluent

final class CharityLog: Model {
    
    static let schema = "CharityLog"
    
    @ID(key: .id)
    var id: UUID?
    
    @OptionalField(key: "charityId")
    var charityId: Int?
    
    @Field(key: "charity")
    var charity: Charity
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(charityId: Int?, charity: Charity) {
        self.charityId = charityId
        self.charity = charity
    }
}
