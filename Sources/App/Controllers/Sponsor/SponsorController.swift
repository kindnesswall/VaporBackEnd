//
//  SponsorController.swift
//  App
//
//  Created by Amir Hossein on 8/26/20.
//

import Vapor

final class SponsorController {
    
    func index(_ req: Request) throws -> EventLoopFuture<[Sponsor]> {
        return Sponsor.query(on: req.db)
            .all()
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let input = try req.content.decode(Sponsor.self)
        guard input.isValid else {
            throw Abort(.invalid)
        }
        return input.create(on: req.db)
            .transform(to: .ok)
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let input = try req.content.decode(Sponsor.self)
        guard input.isValid else {
            throw Abort(.invalid)
        }
        
        return Sponsor.getParameter(on: req).flatMap { sponsor in
            return sponsor.update(input: input, on: req)
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        return Sponsor.getParameter(on: req).flatMap { sponsor in
            return sponsor.delete(on: req.db)
                .transform(to: .ok)
        }
    }
    
}
