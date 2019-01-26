//
//  AuthWebSocket.swift
//  App
//
//  Created by Amir Hossein on 1/26/19.
//

import Vapor


class AuthWebSocket {
    
    public func isAuthenticated(req:Request) throws -> Future<User> {
        
        guard let bearerAuthorization = req.http.headers.bearerAuthorization else {
            throw Constants.errors.unauthorizedSocket
        }
        
        return Token.authenticate(using: bearerAuthorization, on: req).flatMap { (token) -> Future<User> in
            
            guard let token = token else {
                throw Constants.errors.unauthorizedSocket
            }
            
            return User.authenticate(token: token, on: req).map({ (user) -> User in
                guard let user = user else {
                    throw Constants.errors.unauthorizedSocket
                }
                return user
            })
        }
        
    }
}
