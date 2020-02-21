//
//  CategoryController.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor


final class CategoryController {

    func index(_ req: Request) throws -> Future<[Category.Output]> {
        
        return try req.content.decode(Inputs.Country.self).flatMap { input in
            
            return Country.find(input.country_id, on: req).flatMap { country in
                
                guard let country = country else {
                    throw Constants.errors.countryNotFound
                }
                
                return self.localizedCategories(req: req, country: country)
            }
        }
    }
    
    private func localizedCategories(req: Request, country: Country) -> Future<[Category.Output]>  {
        return Category.query(on: req).all().map { categories in
            categories.map { category in
                return category.localized(country: country)
            }
        }
    }
    
}
