//
//  Gift.swift
//  App
//
//  Created by Amir Hossein on 1/10/19.
//

import Vapor
import FluentMySQL

final class Gift : MySQLModel {
    var id:Int?
    var title:String
    var address:String
    var description:String
    var price:String
}

/// Allows `Gift` to be used as a dynamic migration.
extension Gift : Migration {}

/// Allows `Gift` to be encoded to and decoded from HTTP messages.
extension Gift : Content {}

/// Allows `Gift` to be used as a dynamic parameter in route definitions.
extension Gift : Parameter {}
