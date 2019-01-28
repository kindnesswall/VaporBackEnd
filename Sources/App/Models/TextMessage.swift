//
//  TextMessage.swift
//  App
//
//  Created by Amir Hossein on 1/28/19.
//

import Vapor
import FluentPostgreSQL


final class TextMessage : PostgreSQLModel {
    var id:Int?
    var senderId:Int?
    var text:String
    var receiverId:Int
}

extension TextMessage : Migration {}
extension TextMessage : Content {}
extension TextMessage : Parameter {}
