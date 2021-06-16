//
//  CharityController.swift
//  App
//
//  Created by Amir Hossein on 7/17/19.
//

import Vapor

final class CharityController {
    
    func getCharityList(_ req: Request) throws -> EventLoopFuture<[Charity]> {
        
        return Charity.getAllCharities(conn: req).map({ result in
            var list = [Charity]()
            for each in result {
                list.append(each.1)
            }
            return list
        })
        
    }
    
    func getCharityOfUser(_ req: Request) throws -> EventLoopFuture<Charity> {
        
        let userId = req.idParameter
        return User.findOrFail(userId, on: req).flatMap { user in
            guard user.isCharity else {
                throw Abort(.userIsNotCharity)
            }
            return try Charity.get(userId: userId, on: req)
        }
    }
}
