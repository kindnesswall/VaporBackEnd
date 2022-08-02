//
//  CharityAdminController.swift
//  App
//
//  Created by Amir Hossein on 7/21/19.
//

import Vapor

final class CharityAdminController {
    
    func getUnreviewedList(_ req: Request) throws -> EventLoopFuture<[Charity]> {
        
        return Charity.getCharityReviewList(conn: req.db)
    }
    
    func getRejectedList(_ req: Request) throws -> EventLoopFuture<[Charity]> {
        
        return Charity.getCharityRejectedList(conn: req.db)
    }
    
    func acceptCharity(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let userId = try req.requireIDParameter()
        return User.findOrFail(userId, on: req.db).flatMap { user in
            return Charity.get(userId: userId, on: req.db).flatMap { foundCharity in
                foundCharity.isRejected = false
                foundCharity.rejectReason = nil
                return foundCharity.save(on: req.db).flatMap({ _ in
                    user.isCharity = true
                    user.charityName = foundCharity.name
                    user.charityImage = foundCharity.logoImage
                    return user.save(on: req.db)
                        .transform(to: .ok)
                })
            }
        }
    }
    
    func rejectCharity(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let userId = try req.requireIDParameter()
        let input = try req.content.decode(Inputs.RejectReason.self)
        return User.findOrFail(userId, on: req.db).flatMap { user in
            user.isCharity = false
            user.charityName = nil
            user.charityImage = nil
            return user.save(on: req.db).flatMap { _ in
                return Charity.get(userId: userId, on: req.db).flatMap { foundCharity in
                    foundCharity.isRejected = true
                    foundCharity.rejectReason = input.rejectReason
                    return foundCharity.save(on: req.db)
                        .transform(to: .ok)
                }
            }
        }
    }
}
