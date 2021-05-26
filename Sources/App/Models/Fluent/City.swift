//
//  City.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor
import Fluent

final class City : Model{
    
    static let schema = "City"
    
    var id:Int?
    var province_id:Int
    var county_id:Int
    var name:String
    var hasRegions:Bool?
    var sortIndex:Int? 
    
    init() {}
}

extension City {
    var regions : Children<City,Region> {
        return children(\.city_id)
    }
}


//extension City : Migration {}

extension City : Content {}


