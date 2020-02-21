//
//  UserControllerCore.swift
//  App
//
//  Created by Amir Hossein on 11/5/19.
//

import Vapor
import FluentPostgreSQL

class UserControllerCore {
    func findOrInitializeUser(req: Request, phoneNumber: String) -> Future<User>{
        
        return User.query(on: req, withSoftDeleted: true).filter(\User.phoneNumber == phoneNumber).first().map({ (dBUser) -> User in
            
            guard dBUser?.deletedAt == nil else {
                throw Constants.errors.userAccessIsDenied
            }
            
            var user:User
            if let dBUser=dBUser {
                user = dBUser
            } else {
                user = User(phoneNumber: phoneNumber)
            }
            
            return user
        })
        
    }
    
    func getToken(req: Request, user: User) throws -> Future<AuthOutput> {
        let token = try Token.generate(for: user)
        
        return token.save(on: req).map({ token in
            return AuthOutput(token: token, isAdmin: user.isAdmin, isCharity: user.isCharity)
        })
    }
}
