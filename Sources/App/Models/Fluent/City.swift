//
//  City.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor
import Fluent

final class City : Model{
    
    static let schema = "City"
    
    @ID(custom: .id)
    var id:Int?
    
    @Parent(key: "province_id")
    var province: Province
    
    @Field(key: "county_id")
    var county_id:Int
    
    @Field(key: "name")
    var name:String
    
    @OptionalField(key: "hasRegions")
    var hasRegions:Bool?
    
    @OptionalField(key: "sortIndex")
    var sortIndex:Int?
    
    @Children(for: \.$city)
    var regions: [Region]
    
    init() {}
    
    var outputObject: Output {
        .init(
            id: id,
            province_id: $province.id,
            county_id: county_id,
            name: name,
            hasRegions: hasRegions,
            sortIndex: sortIndex)
    }
    
    struct Output: Content {
        let id:Int?
        let province_id:Int
        let county_id:Int
        let name:String
        let hasRegions:Bool?
        let sortIndex:Int? 
    }
}


//extension City : Migration {}

extension City : Content {}

extension Array where Element == City {
    var outputArray: [City.Output] {
        map { $0.outputObject }
    }
}

extension EventLoopFuture where Value == [City] {
    var outputArray: EventLoopFuture<[City.Output]> {
        map { $0.outputArray }
    }
}
