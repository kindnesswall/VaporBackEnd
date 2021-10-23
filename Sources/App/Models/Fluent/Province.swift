//
//  Province.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor
import Fluent

final class Province: Model {
    
    static let schema = "Province"
    
    @ID(custom: .id)
    var id:Int?
    
    @Field(key: "name")
    var name:String
    
    @Parent(key: "country_id")
    var country: Country
    
    @OptionalField(key: "sortIndex")
    var sortIndex:Int?
    
    @Children(for: \.$province)
    var cities: [City]
    
    init() {}
}

//extension Province : Migration {}

extension Province : Content {}


