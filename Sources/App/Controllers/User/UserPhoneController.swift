//
//  UserPhoneController.swift
//  App
//
//  Created by Amir Hossein on 5/1/21.
//

import Vapor

final class UserPhoneController {
    
    func getPhoneNumber(_ req: Request) throws -> EventLoopFuture<Outputs.UserPhoneNumber> {
        
        let authId = try req.auth.require(User.self).getId()
        
        return try getUserIfPhoneNumberIsAccessible(req)
            .unwrap(or: Abort(.phoneNumberIsNotAccessible))
            .flatMap { user in
                
                guard let userId = user.id else {
                    return req.db.makeFailedFuture(.nilUserId)
                }
                
                let log = PhoneNumberSeenLog(
                    fromUserId: authId,
                    seenUserId: userId,
                    seenPhoneNumber: user.phoneNumber)
                
                let output = Outputs.UserPhoneNumber(phoneNumber: user.phoneNumber)
                
                return log.create(on: req.db)
                    .transform(to: output)
        }
    }
    
    private func getUserIfPhoneNumberIsAccessible(_ req: Request) throws -> EventLoopFuture<User?> {
        let auth = try req.auth.require(User.self)
        let isAdmin = auth.isAdmin
        let isCharity = auth.isCharity
        
        return User.getParameter(on: req).map { user in
            
            let isPhoneVisibleForAll = user.isPhoneVisibleForAll ?? false
            let isPhoneVisibleForCharities = user.isPhoneVisibleForCharities ?? false
            
            guard isAdmin || isPhoneVisibleForAll || (isCharity && isPhoneVisibleForCharities) else {
                return nil
            }
            return user
        }
    }
}
