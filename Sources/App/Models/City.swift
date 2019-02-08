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
}


extension City : Migration {}

extension City : Content {}

extension City : Parameter {}
