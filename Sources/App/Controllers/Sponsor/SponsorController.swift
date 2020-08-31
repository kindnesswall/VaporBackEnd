//
//  SponsorController.swift
//  App
//
//  Created by Amir Hossein on 8/26/20.
//

import Vapor

final class SponsorController {
    
    func index(_ req: Request) throws -> Future<[Sponsor]> {
        return Sponsor.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.content.decode(Sponsor.self).flatMap { input in
            guard input.isValid else {
                return req.future(error: Abort(.invalid))
            }
            return input.create(on: req).transform(to: .ok)
        }
    }
    
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        
        let updatedId = try req.parameters.next(Int.self)
        
        return Sponsor.get(updatedId, on: req).flatMap { sponsor in
            
            return try req.content.decode(Sponsor.self).flatMap { input in
                guard input.isValid else {
                    return req.future(error: Abort(.invalid))
                }
                return sponsor.update(input: input, on: req)
            }
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        
        let deletedId = try req.parameters.next(Int.self)
        
        return Sponsor.get(deletedId, on: req).flatMap { sponsor in
            return sponsor.delete(on: req).transform(to: .ok)
        }
    }
    
}
