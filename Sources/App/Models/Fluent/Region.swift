//
//  Region.swift
//  App
//
//  Created by Amir Hossein on 8/9/19.
//

import Vapor
import Fluent

final class Region : Model {
    
    static let schema = "Region"
    
    @ID(custom: .id)
    var id:Int?
    
    @Parent(key: "city_id")
    var city: City
    
    @Field(key: "name")
    var name:String
    
    @OptionalField(key: "latitude")
    var latitude:Double?
    
    @OptionalField(key: "longitude")
    var longitude:Double?
    
    @OptionalField(key: "sortIndex")
    var sortIndex:Int? 
    
    init() {}
    
    var outputObject: Output {
        .init(
            id: id,
            city_id: $city.id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            sortIndex: sortIndex)
    }
    
    struct Output: Content {
        let id:Int?
        let city_id:Int
        let name:String
        let latitude:Double?
        let longitude:Double?
        let sortIndex:Int?
    }
    
}


//extension Region : Migration {}

extension Region : Content {}

extension Array where Element == Region {
    var outputArray: [Region.Output] {
        map { $0.outputObject }
    }
}

extension EventLoopFuture where Value == [Region] {
    var outputArray: EventLoopFuture<[Region.Output]> {
        map { $0.outputArray }
    }
}
