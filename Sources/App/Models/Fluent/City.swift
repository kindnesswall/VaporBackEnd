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
    
    @ID(key: .id)
    var id:Int?
    
    @Field(key: "province_id")
    var province_id:Int
    
    @Field(key: "county_id")
    var county_id:Int
    
    @Field(key: "name")
    var name:String
    
    @OptionalField(key: "hasRegions")
    var hasRegions:Bool?
    
    @OptionalField(key: "sortIndex")
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


