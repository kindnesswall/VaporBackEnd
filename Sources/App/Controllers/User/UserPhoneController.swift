//
//  UserPhoneController.swift
//  App
//
//  Created by Amir Hossein on 5/1/21.
//

import Vapor

final class UserPhoneController {
    
    func checkPhoneNumberAccessibility(_ req: Request) throws -> Future<Bool> {
        try getUserIfPhoneNumberIsAccessible(req).map { user in
            return user != nil
        }
    }
    
    func getPhoneNumber(_ req: Request) throws -> Future<Outputs.UserPhoneNumber> {
        try getUserIfPhoneNumberIsAccessible(req).map { user in
            guard let user = user else {
                throw Abort(.phoneNumberIsNotAccessible)
            }
            return Outputs.UserPhoneNumber(phoneNumber: user.phoneNumber)
        }
    }
    
    private func getUserIfPhoneNumberIsAccessible(_ req: Request) throws -> Future<User?> {
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
