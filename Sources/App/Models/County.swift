//
//  County.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor
import FluentPostgreSQL

final class County : PostgreSQLModel{
    var id:Int?
    var province_id:Int
    var name:String
}


extension County : Migration {}

extension County : Content {}

extension County : Parameter {}
