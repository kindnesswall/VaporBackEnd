//
//  CharityAdminController.swift
//  App
//
//  Created by Amir Hossein on 7/21/19.
//

import Vapor

final class CharityAdminController {
    
    func getUnreviewedList(_ req: Request) throws -> Future<[Charity_UserProfile]> {
        
        return Charity.getCharityReviewList(conn: req).map { result in
            var list = [Charity_UserProfile]()
            for each in result {
                list.append(try Charity_UserProfile(charity: each.0, user: each.1, req: req))
            }
            return list
        }
    }
    
    func acceptCharity(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            
            return try Charity.get(userId: try user.getId(), conn: req).flatMap { foundCharity in
                foundCharity.isRejected = false
                return foundCharity.save(on: req).flatMap({ _ in
                    user.isCharity = true
                    return user.save(on: req).transform(to: .ok)
                })
            }
        }
    }
    
    func rejectCharity(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { user in
            user.isCharity = false
            return user.save(on: req).flatMap { _ in
                return try Charity.get(userId: try user.getId(), conn: req).flatMap { foundCharity in
                    foundCharity.isRejected = true
                    return foundCharity.save(on: req).transform(to: .ok)
                }
            }
        }
    }
}
