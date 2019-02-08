//
//  LocationController.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor


final class LocationController {
    
    func getProvinces(_ req: Request) throws -> Future<[Province]> {
        return Province.query(on: req).all()
    }
    
    func getCities(_ req: Request) throws -> Future<[City]> {
        return try req.parameters.next(Province.self).flatMap({ province in
            return try province.cities.query(on: req).all()
        })
    }
    
}
