//
//  CategoryController.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor


final class CategoryController {

    func index(_ req: Request) throws -> EventLoopFuture<[Category.Output]> {
        
        let input = try req.content.decode(Inputs.Country.self)
        
        return Country.findOrFail(
            input.countryId,
            on: req.db,
            error: .countryNotFound).flatMap { country in
            
            return self.localizedCategories(req: req, country: country)
        }
    }
    
    private func localizedCategories(req: Request, country: Country) -> EventLoopFuture<[Category.Output]>  {
        return Category.query(on: req.db)
            .all()
            .map { categories in
                categories.map { category in
                    return category.localized(country: country)
                }
        }
    }
    
}
