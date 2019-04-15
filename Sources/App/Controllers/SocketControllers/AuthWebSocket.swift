//
//  AuthWebSocket.swift
//  App
//
//  Created by Amir Hossein on 1/26/19.
//

import Vapor


class AuthWebSocket {
    
    public func isAuthenticated(bearerAuthorization:BearerAuthorization,socketDB:SocketDataBaseController) throws -> Future<User> {
        
        return socketDB.isTokenAuthenticated(bearerAuthorization: bearerAuthorization).flatMap { (token) -> Future<User> in
            
            guard let token = token else {
                throw Constants.errors.unauthorizedSocket
            }
            
            return socketDB.isUserAuthenticated(token: token).map({ (user) -> User in
                guard let user = user else {
                    throw Constants.errors.unauthorizedSocket
                }
                return user
            })
        }
        
    }
}
