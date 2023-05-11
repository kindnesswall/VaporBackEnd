//
//  CharityInfoController.swift
//  App
//
//  Created by Amir Hossein on 6/29/20.
//

import Vapor

final class CharityInfoController {
    
    private func validate(_ req: Request) throws -> Int {
        
        let auth = try req.auth.require(User.self)
        let userId = try req.requireIDParameter()
        
        guard auth.isAdmin || auth.id == userId else {
            throw Abort(.unauthorizedRequest)
        }
        return userId
    }
    
    func show(_ req: Request) throws -> EventLoopFuture<CharityDetailedStatus> {
        
        let userId = try validate(req)
        
        return User.findOrFail(userId, on: req.db).flatMap { user in
            return Charity.find(userId: userId, on: req.db).map { charity in
                return .init(user: user, charity: charity)
            }
        }
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Charity> {
        
        let userId = try validate(req)
        let input = try req.content.decode(Charity.Input.self)
        
        return Charity.hasFound(userId: userId, on: req.db).flatMap { hasFound in
            guard !hasFound else {
                return req.db.makeFailedFuture(.charityInfoAlreadyExists)
            }
            return Charity
                .create(userId: userId, input, on: req.db)
        }
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Charity> {
        
        let userId = try validate(req)
        let input = try req.content.decode(Charity.Input.self)
        
        return Charity.get(userId: userId, on: req.db).flatMap { charity in
            let log = CharityLog(charityId: charity.id, charity: charity)
            return log.create(on: req.db).flatMap {
                return charity.update(input, on: req.db).flatMap {
                    return User.findOrFail(userId, on: req.db).flatMap { user in
                        if user.isCharity {
                            user.charityName = charity.name
                            user.charityImage = charity.logoImage
                        }
                        return user.update(on: req.db)
                            .transform(to: charity)
                    }
                }
            }
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let userId = try validate(req)
        
        return Charity.get(userId: userId, on: req.db).flatMap { charity in
            let log = CharityLog(charityId: charity.id, charity: charity)
            return log.create(on: req.db).flatMap {
                return User.findOrFail(userId, on: req.db).flatMap { user in
                    
                    user.isCharity = false
                    user.charityName = nil
                    user.charityImage = nil
                    
                    return user.update(on: req.db).flatMap {
                        return charity
                            .delete(force: true, on: req.db)
                            .transform(to: .ok)
                    }
                }
            }
        }
    }
}
