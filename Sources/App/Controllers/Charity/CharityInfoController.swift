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
    
    func show(_ req: Request) throws -> EventLoopFuture<Charity_Status> {
        
        let userId = try validate(req)
        
        return User.findOrFail(userId, on: req.db).flatMap { user in
            return Charity.find(userId: userId, on: req.db).map { charity in
                let status = self.getCharityStatus(user: user, charity: charity)
                return Charity_Status(charity: charity, status: status)
            }
        }
    }
    
    private func getCharityStatus(user: User, charity: Charity?) -> CharityStatus {
        
        if let charity = charity {
            if user.isCharity {
                return .isCharity
            } else {
                if charity.isRejected == true {
                    return .rejected
                } else {
                    return .pending
                }
            }
        } else {
            return .notRequested
        }
        
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Charity> {
        
        let userId = try validate(req)
        let input = try req.content.decode(Charity.Input.self)
        
        return Charity.hasFound(userId: userId, on: req.db).flatMap { hasFound in
            guard !hasFound else {
                return req.db.makeFailedFuture(.charityInfoAlreadyExists)
            }
            let charity = Charity(input: input, userId: userId)
            return charity.save(on: req.db)
                .transform(to: charity)
        }
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Charity> {
        
        let userId = try validate(req)
        let input = try req.content.decode(Charity.Input.self)
        
        return Charity.get(userId: userId, on: req.db).flatMap { charity in
            charity.update(input: input)
            return charity.save(on: req.db).flatMap { _ in
                return User.findOrFail(userId, on: req.db).flatMap { user in
                    if user.isCharity {
                        user.charityName = charity.name
                        user.charityImage = charity.imageUrl
                    }
                    return user.save(on: req.db)
                        .transform(to: charity)
                }
            }
            
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let userId = try validate(req)
        
        return User.findOrFail(userId, on: req.db).flatMap { user in
            
            user.isCharity = false
            user.charityName = nil
            user.charityImage = nil
            
            return user.save(on: req.db).flatMap { _ in
                return Charity.get(userId: userId, on: req.db).flatMap { foundCharity in
                    return foundCharity.delete(on: req.db)
                        .transform(to: .ok)
                }
            }
        }
    }
}
