//
//  Region.swift
//  App
//
//  Created by Amir Hossein on 8/9/19.
//

import Vapor
import Fluent

final class Region : Model {
    
    static let schema = "Region"
    
    @ID(key: .id)
    var id:Int?
    
    @Field(key: "city_id")
    var city_id:Int
    
    @Field(key: "name")
    var name:String
    
    @OptionalField(key: "latitude")
    var latitude:Double?
    
    @OptionalField(key: "longitude")
    var longitude:Double?
    
    @OptionalField(key: "sortIndex")
    var sortIndex:Int? 
    
    init() {}
    
}


//extension Region : Migration {}

extension Region : Content {}


