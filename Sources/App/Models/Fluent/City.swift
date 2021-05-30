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
    
    @Parent(key: "province_id")
    var province: Province
    
    @Field(key: "county_id")
    var county_id:Int
    
    @Field(key: "name")
    var name:String
    
    @OptionalField(key: "hasRegions")
    var hasRegions:Bool?
    
    @OptionalField(key: "sortIndex")
    var sortIndex:Int?
    
    @Children(for: \.$city)
    var regions: [Region]
    
    init() {}
}


//extension City : Migration {}

extension City : Content {}


