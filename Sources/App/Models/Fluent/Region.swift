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
    
    var id:Int?
    var city_id:Int
    var name:String
    var latitude:Double?
    var longitude:Double?
    var sortIndex:Int? 
    
    init() {}
    
}


//extension Region : Migration {}

extension Region : Content {}


