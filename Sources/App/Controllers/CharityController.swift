//
//  CharityController.swift
//  App
//
//  Created by Amir Hossein on 7/17/19.
//

import Vapor

final class CharityController {
    
    func getCharityList(_ req: Request) throws -> Future<[Charity]> {
        
        return Charity.getAllCharities(conn: req).map({ result in
            var list = [Charity]()
            for each in result {
                list.append(each.1)
            }
            return list
        })
        
    }
    
    func getCharityInfo(_ req: Request) throws -> Future<Charity> {
        return try req.parameters.next(User.self).flatMap { selectedUser in
            guard selectedUser.isCharity else {
                throw Constants.errors.userIsNotCharity
            }
            return try Charity.get(userId: try selectedUser.getId(), conn: req)
        }
    }
    
    func show(_ req: Request) throws -> Future<CharityInfoStatus> {
        let user = try req.requireAuthenticated(User.self)
        return Charity.find(userId: try user.getId(), conn: req).map({ charity in
            let isCreated = charity != nil ? true : false
            return CharityInfoStatus(isCreated: isCreated, charity: charity)
        })
    }
    
    
    func create(_ req: Request) throws -> Future<Charity> {
        
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.getId()
        return Charity.hasFound(userId: userId, conn: req).flatMap { hasFound in
            guard !hasFound else {
                throw Constants.errors.charityInfoAlreadyExists
            }
            
            return try req.content.decode(Charity.self).flatMap({ charityInput in
                return charityInput.createCharity(userId: userId, conn: req)
            })
        }
    }
    
    func update(_ req: Request) throws -> Future<Charity> {
        
        let user = try req.requireAuthenticated(User.self)
        
        return try Charity.get(userId: try user.getId(), conn: req).flatMap { foundCharity in
            
            return try req.content.decode(Charity.self).flatMap({ charityInput in
                return charityInput.updateCharity(original: foundCharity, conn: req)
            })
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        
        let user = try req.requireAuthenticated(User.self)
        user.isCharity = false
        return user.save(on: req).flatMap { _ in
            return try Charity.get(userId: try user.getId(), conn: req).flatMap({ foundCharity in
                return foundCharity.delete(on: req).transform(to: .ok)
            })
        }
    }
}
