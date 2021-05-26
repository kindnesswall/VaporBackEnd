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
    
    var id:Int?
    var name:String
    var phoneCode: String?
    var localization: String?
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


