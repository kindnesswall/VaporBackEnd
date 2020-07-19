//
//  CharityInfoController.swift
//  App
//
//  Created by Amir Hossein on 6/29/20.
//

import Vapor

final class CharityInfoController {
    
    private func validate(_ req: Request) throws -> Int {
        
        let auth = try req.requireAuthenticated(User.self)
        let userId = try req.parameters.next(Int.self)
        
        guard auth.isAdmin || auth.id == userId else {
            throw Abort(.unauthorizedRequest)
        }
        return userId
    }
    
    func show(_ req: Request) throws -> Future<Charity_Status> {
        
        let userId = try validate(req)
        
        return User.get(userId, on: req).flatMap { user in
            return Charity.find(userId: userId, on: req).map { charity in
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
    
    func create(_ req: Request) throws -> Future<Charity> {
        
        let userId = try validate(req)
        
        return Charity.hasFound(userId: userId, on: req).flatMap { hasFound in
            guard !hasFound else {
                throw Abort(.charityInfoAlreadyExists)
            }
            return try req.content.decode(Charity.Input.self).flatMap { input in
                return Charity(input: input, userId: userId).save(on: req)
            }
        }
    }
    
    func update(_ req: Request) throws -> Future<Charity> {
        
        let userId = try validate(req)
        
        return try Charity.get(userId: userId, on: req).flatMap { charity in
            
            return try req.content.decode(Charity.Input.self).flatMap { input in
                
                charity.update(input: input)
                return charity.save(on: req).flatMap { charity in
                    return User.get(userId, on: req).flatMap { user in
                        if user.isCharity {
                            user.charityName = input.name
                            user.charityImage = input.imageUrl
                        }
                        return user.save(on: req).transform(to: charity)
                    }
                }
            }
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        
        let userId = try validate(req)
        
        return User.get(userId, on: req).flatMap { user in
            
            user.isCharity = false
            user.charityName = nil
            user.charityImage = nil
            
            return user.save(on: req).flatMap { _ in
                return try Charity.get(userId: userId, on: req).flatMap({ foundCharity in
                    return foundCharity.delete(on: req).transform(to: .ok)
                })
            }
        }
    }
}
