//
//  County.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor
import Fluent

final class County : Model{
    
    static let schema = "County"
    
    @ID(custom: .id)
    var id:Int?
    
    @Field(key: "province_id")
    var province_id:Int
    
    @Field(key: "name")
    var name:String
    
    @OptionalField(key: "sortIndex")
    var sortIndex:Int? 
    
    init() {}
    
}


//extension County : Migration {}

extension County : Content {}

