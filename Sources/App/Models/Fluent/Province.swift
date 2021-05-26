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
    
    var id:Int?
    var name:String
    var country_id: Int
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


