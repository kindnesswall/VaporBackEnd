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
    
    func getCharityOfUser(_ req: Request) throws -> EventLoopFuture<CharityStatus> {
        
        let userId = try req.idParameter ?? req.requireAuthID()
        return User.findOrFail(userId, on: req.db).flatMap { user in
            if !user.isCharity {
                return req.db.makeSucceededFuture(.init(isCharity: false))
            } else {
                return Charity.get(userId: userId, on: req.db).map { charity in
                    return .init(charity: charity, isCharity: true)
                }
            }
        }
    }
}
