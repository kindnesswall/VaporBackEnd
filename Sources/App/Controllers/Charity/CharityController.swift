//
//  CharityController.swift
//  App
//
//  Created by Amir Hossein on 7/17/19.
//

import Vapor

final class CharityController {
    
    func getCharityList(_ req: Request) throws -> EventLoopFuture<[Charity]> {
        return Charity.getAllCharities(conn: req.db)
    }
    
    func getCharityOfUser(_ req: Request) throws -> EventLoopFuture<Charity> {
        
        let userId = try req.requireIDParameter()
        return User.findOrFail(userId, on: req.db).flatMap { user in
            guard user.isCharity else {
                return req.db.makeFailedFuture(.userIsNotCharity)
            }
            return Charity.get(userId: userId, on: req.db)
        }
    }
}
