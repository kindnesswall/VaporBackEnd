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
    
    @ID(key: .id)
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
    
    init() {}
    
}

extension Country {
    var provinces: Children<Country, Province> {
        return children(\.country_id)
    }
}

//extension Country : Migration {}

extension Country : Content {}


