//
//  Region.swift
//  App
//
//  Created by Amir Hossein on 8/9/19.
//

import Vapor
import FluentPostgreSQL


final class Region : PostgreSQLModel {
    var id:Int?
    var city_id:Int
    var name:String
    var longitude:Double
    var latitude:Double
}


extension Region : Migration {}

extension Region : Content {}

extension Region : Parameter {}
