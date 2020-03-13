//
//  AuthWebSocket.swift
//  App
//
//  Created by Amir Hossein on 1/26/19.
//

import Vapor


class AuthWebSocket {
    
    public func isAuthenticated(bearerAuthorization:BearerAuthorization,dataBase:ChatDataBase) throws -> Future<User> {
        
        return dataBase.isTokenAuthenticated(bearerAuthorization: bearerAuthorization).flatMap { (token) -> Future<User> in
            
            guard let token = token else {
                throw Constants.errors.unauthorizedSocket
            }
            
            return dataBase.isUserAuthenticated(token: token).map({ (user) -> User in
                guard let user = user else {
                    throw Constants.errors.unauthorizedSocket
                }
                return user
            })
        }
        
    }
}
