//
//  Country.swift
//  App
//
//  Created by Amir Hossein on 2/18/20.
//

import Vapor
import FluentPostgreSQL

final class Country: PostgreSQLModel {
    var id:Int?
    var name:String
    var sortIndex:Int?
    var localization: String?
    
    var isFarsi: Bool {
        return localization == "fa"
    }
}

extension Country {
    var provinces: Children<Country, Province> {
        return children(\.country_id)
    }
}

extension Country : Migration {}

extension Country : Content {}

extension Country : Parameter {}
