//
//  Category.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor
import Fluent

final class Category : Model {
    
    static let schema = "Category"
    
    @ID(key: .id)
    var id:Int?
    
    @Field(key: "title")
    var title:String
    
    @OptionalField(key: "title_fa")
    var title_fa:String?
    
    @Children(for: \.$category)
    var gifts: [Gift]
    
    init() {}
    
    init(id:Int?=nil,title:String, title_fa:String?) {
        self.id=id
        self.title=title
        self.title_fa = title_fa
    }
    
    final class Output: Content {
        var id:Int?
        var title:String
        
        init(id:Int?, title:String) {
            self.id = id
            self.title = title
        }
    }
    
    func localized(country: Country) -> Output {
        return Output(id: id, title: localizedTitle(country: country))
    }
    
    func localizedTitle(country: Country) -> String {
        return country.isFarsi ? (title_fa ?? title) : title
    }
}

//extension Category : Migration {}

extension Category : Content {}

