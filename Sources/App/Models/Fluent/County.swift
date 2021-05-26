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
    
    var id:Int?
    var province_id:Int
    var name:String
    var sortIndex:Int? 
    
    init() {}
    
}


//extension County : Migration {}

extension County : Content {}

