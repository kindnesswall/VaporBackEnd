//
//  CategoryController.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor


final class CategoryController {

    func index(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
}
