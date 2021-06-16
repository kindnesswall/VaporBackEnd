//
//  CharityAdminController.swift
//  App
//
//  Created by Amir Hossein on 7/21/19.
//

import Vapor

final class CharityAdminController {
    
    func getUnreviewedList(_ req: Request) throws -> EventLoopFuture<[Charity]> {
        
        return Charity.getCharityReviewList(conn: req)
    }
    
    func getRejectedList(_ req: Request) throws -> EventLoopFuture<[Charity]> {
        
        return Charity.getCharityRejectedList(conn: req)
    }
    
    func acceptCharity(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return User.getParameter(on: req).flatMap { user in
            
            return try Charity.get(userId: try user.getId(), on: req).flatMap { foundCharity in
                foundCharity.isRejected = false
                foundCharity.rejectReason = nil
                return foundCharity.save(on: req).flatMap({ _ in
                    user.isCharity = true
                    user.charityName = foundCharity.name
                    user.charityImage = foundCharity.imageUrl
                    return user.save(on: req).transform(to: .ok)
                })
            }
        }
    }
    
    func rejectCharity(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return User.getParameter(on: req).flatMap { user in
            
            return try req.content.decode(Inputs.RejectReason.self).flatMap({ input in 
                
                user.isCharity = false
                user.charityName = nil
                user.charityImage = nil
                
                return user.save(on: req).flatMap { _ in
                    return try Charity.get(userId: try user.getId(), on: req).flatMap { foundCharity in
                        foundCharity.isRejected = true
                        foundCharity.rejectReason = input.rejectReason
                        return foundCharity.save(on: req).transform(to: .ok)
                    }
                }
            })
        }
    }
}
