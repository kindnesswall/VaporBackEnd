//
//  LocationController.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor


final class LocationController {
    
    func getProvinces(_ req: Request) throws -> Future<[Province]> {
        return Province.query(on: req)
            .sort(\.sortIndex, .ascending)
            .sort(\.id, .ascending)
            .all()
    }
    
    func getCities(_ req: Request) throws -> Future<[City]> {
        return try req.parameters.next(Province.self).flatMap({ province in
            return try province.cities.query(on: req)
                .sort(\.sortIndex, .ascending)
                .sort(\.id, .ascending)
                .all() 
        })
    }
    func getRegions(_ req: Request) throws -> Future<[Region]> {
        return try req.parameters.next(City.self).flatMap({ city in
            return try city.regions.query(on: req)
                .sort(\.sortIndex, .ascending)
                .sort(\.id, .ascending)
                .all()
        })
    }
    
}
