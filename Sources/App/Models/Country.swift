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
    var exclusiveAddress: String?
    
    
    var isFarsi: Bool {
        return localization == "fa"
    }
}

extension Country : Migration {}

extension Country : Content {}

extension Country : Parameter {}
