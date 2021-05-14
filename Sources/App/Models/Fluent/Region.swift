//
//  Region.swift
//  App
//
//  Created by Amir Hossein on 8/9/19.
//

import Vapor
import Fluent
import FluentPostgresDriver


final class Region : PostgreSQLModel {
    var id:Int?
    var city_id:Int
    var name:String
    var latitude:Double?
    var longitude:Double?
    var sortIndex:Int? 
}


//extension Region : Migration {}

extension Region : Content {}

extension Region : Parameter {}
