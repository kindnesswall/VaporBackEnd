//
//  UserPhoneController.swift
//  App
//
//  Created by Amir Hossein on 5/1/21.
//

import Vapor

final class UserPhoneController {
    
    func checkPhoneNumberAccessibility(_ req: Request) throws -> EventLoopFuture<Outputs.UserPhoneNumberCheck> {
        return try getUserIfPhoneNumberIsAccessible(req).map { user in
            return user != nil
        }
        .map {Outputs.UserPhoneNumberCheck(isVisible: $0)}
    }
    
    func getPhoneNumber(_ req: Request) throws -> EventLoopFuture<Outputs.UserPhoneNumber> {
        
        let authId = try req.requireAuthenticated(User.self).getId()
        
        return try getUserIfPhoneNumberIsAccessible(req).flatMap { user in
            guard let user = user else {
                throw Abort(.phoneNumberIsNotAccessible)
            }
            
            let log = try PhoneNumberSeenLog(
                fromUserId: authId,
                seenUserId: user.getId(),
                seenPhoneNumber: user.phoneNumber)
            
            let output = Outputs.UserPhoneNumber(phoneNumber: user.phoneNumber)
            
            return log.create(on: req).transform(to: output)
        }
    }
    
    private func getUserIfPhoneNumberIsAccessible(_ req: Request) throws -> EventLoopFuture<User?> {
        let auth = try req.requireAuthenticated(User.self)
        let isAdmin = auth.isAdmin
        let isCharity = auth.isCharity
        let userId = try req.parameters.next(Int.self)
        
        return User.get(userId, on: req).map { user in
            
            let isPhoneVisibleForAll = user.isPhoneVisibleForAll ?? false
            let isPhoneVisibleForCharities = user.isPhoneVisibleForCharities ?? false
            
            guard isAdmin || isPhoneVisibleForAll || (isCharity && isPhoneVisibleForCharities) else {
                return nil
            }
            return user
        }
    }
}
