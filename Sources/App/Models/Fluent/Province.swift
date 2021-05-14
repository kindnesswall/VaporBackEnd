//
//  Province.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor
import Fluent
import FluentPostgresDriver


final class Province: PostgreSQLModel {
    var id:Int?
    var name:String
    var country_id: Int
    var sortIndex:Int?
}

extension Province {
    var cities : Children<Province,City> {
        return children(\.province_id)
    }
}

extension Province : Migration {}

extension Province : Content {}

extension Province : Parameter {}
