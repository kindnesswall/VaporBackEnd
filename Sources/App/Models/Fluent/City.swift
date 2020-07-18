//
//  City.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor
import FluentPostgreSQL


final class City : PostgreSQLModel{
    var id:Int?
    var province_id:Int
    var county_id:Int
    var name:String
    var hasRegions:Bool?
    var sortIndex:Int? 
}

extension City {
    var regions : Children<City,Region> {
        return children(\.city_id)
    }
}


extension City : Migration {}

extension City : Content {}

extension City : Parameter {}
