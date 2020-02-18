//
//  Category.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor
import FluentPostgreSQL

final class Category : PostgreSQLModel {
    var id:Int?
    var title:String
    var title_fa:String?
    
    init(id:Int?=nil,title:String, title_fa:String?) {
        self.id=id
        self.title=title
        self.title_fa = title_fa
    }
}

extension Category {
    var gifts : Children<Category,Gift> {
        return children(\.categoryId)
    }
}

extension Category : Migration {}

extension Category : Content {}

extension Category : Parameter {}
