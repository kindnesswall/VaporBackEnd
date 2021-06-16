//
//  LocationController.swift
//  App
//
//  Created by Amir Hossein on 2/8/19.
//

import Vapor


final class LocationController {
    
    func getCountries(_ req: Request) throws -> EventLoopFuture<[Country]> {
        return Country.query(on: req)
            .sort(\.sortIndex, .ascending)
            .sort(\.id, .ascending)
            .all()
    }
    
    func getProvinces(_ req: Request) throws -> EventLoopFuture<[Province]> {
        return Country.getParameter(on: req).flatMap { country in
            return try country.provinces.query(on: req)
                .sort(\.sortIndex, .ascending)
                .sort(\.id, .ascending)
                .all()
        }
    }
    
    func getCities(_ req: Request) throws -> EventLoopFuture<[City]> {
        return Province.getParameter(on: req).flatMap({ province in
            return try province.cities.query(on: req)
                .sort(\.sortIndex, .ascending)
                .sort(\.id, .ascending)
                .all() 
        })
    }
    func getRegions(_ req: Request) throws -> EventLoopFuture<[Region]> {
        return City.getParameter(on: req).flatMap({ city in
            return try city.regions.query(on: req)
                .sort(\.sortIndex, .ascending)
                .sort(\.id, .ascending)
                .all()
        })
    }
    
}
