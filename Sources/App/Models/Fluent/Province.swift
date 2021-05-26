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
    
    @ID(key: .id)
    var id:Int?
    
    @Field(key: "name")
    var name:String
    
    @Field(key: "country_id")
    var country_id: Int
    
    @OptionalField(key: "sortIndex")
    var sortIndex:Int?
    
    init() {}
}

extension Province {
    var cities : Children<Province,City> {
        return children(\.province_id)
    }
}

//extension Province : Migration {}

extension Province : Content {}


