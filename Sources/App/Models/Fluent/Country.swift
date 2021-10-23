//
//  Country.swift
//  App
//
//  Created by Amir Hossein on 2/18/20.
//

import Vapor
import Fluent

final class Country: Model {
    
    static let schema = "Country"
    
    @ID(custom: .id)
    var id:Int?
    
    @Field(key: "name")
    var name:String
    
    @OptionalField(key: "phoneCode")
    var phoneCode: String?
    
    @OptionalField(key: "localization")
    var localization: String?
    
    @OptionalField(key: "sortIndex")
    var sortIndex:Int?
    
    var isFarsi: Bool {
        return localization == "fa"
    }
    
    @Children(for: \.$country)
    var provinces: [Province]
    
    init() {}
    
}

//extension Country : Migration {}

extension Country : Content {}


