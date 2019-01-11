//
//  Category.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor
import FluentMySQL

final class Category : MySQLModel {
    var id:Int?
    var title:String
    
    init(id:Int?=nil,title:String) {
        self.id=id
        self.title=title
    }
}

extension Category : Migration {}

extension Category : Content {}

extension Category : Parameter {}
