//
//  CharityAdminController.swift
//  App
//
//  Created by Amir Hossein on 7/21/19.
//

import Vapor

final class CharityAdminController {
    
    func getUnreviewedList(_ req: Request) throws -> Future<[Charity]> {
        
        return Charity.getCharityReviewList(conn: req)
    }
    
    func getRejectedList(_ req: Request) throws -> Future<[Charity]> {
        
        return Charity.getCharityRejectedList(conn: req)
    }
    
    func acceptCharity(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            
            return try Charity.get(userId: try user.getId(), conn: req).flatMap { foundCharity in
                foundCharity.isRejected = false
                foundCharity.rejectReason = nil
                return foundCharity.save(on: req).flatMap({ _ in
                    user.isCharity = true
                    return user.save(on: req).transform(to: .ok)
                })
            }
        }
    }
    
    func rejectCharity(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            
            return try req.content.decode(Inputs.RejectReason.self).flatMap({ input in 
                
                user.isCharity = false
                return user.save(on: req).flatMap { _ in
                    return try Charity.get(userId: try user.getId(), conn: req).flatMap { foundCharity in
                        foundCharity.isRejected = true
                        foundCharity.rejectReason = input.rejectReason
                        return foundCharity.save(on: req).transform(to: .ok)
                    }
                }
            })
        }
    }
}
