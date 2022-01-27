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
    
    var outputObject: Output {
        .init(
            id: id,
            name: name,
            country_id: $country.id,
            sortIndex: sortIndex)
    }
    
    struct Output: Content {
        let id:Int?
        let name:String
        let country_id: Int
        let sortIndex:Int?
    }
}

//extension Province : Migration {}

extension Province : Content {}

extension Array where Element == Province {
    var outputArray: [Province.Output] {
        map { $0.outputObject }
    }
}

extension EventLoopFuture where Value == [Province] {
    var outputArray: EventLoopFuture<[Province.Output]> {
        map { $0.outputArray }
    }
}
