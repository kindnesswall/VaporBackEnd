//
//  LogoutController.swift
//  App
//
//  Created by Amir Hossein on 4/30/20.
//

import Vapor

class LogoutController {
    
    func logout(_ req: Request) throws -> Future<HTTPStatus> {
        let authToken = try req.requireAuthenticated(Token.self)
        return try LogoutController.logout(req: req, userToken: authToken)
    }
    
    func logoutAllDevices(_ req: Request) throws -> Future<HTTPStatus> {

        let auth = try req.requireAuthenticated(User.self)
        return try LogoutController.logoutAllDevices(req: req, user: auth)
    }
    
    static func logoutAllDevices(req: Request, user:User) throws -> Future<HTTPStatus> {
        
        let userId = try user.getId()
        return try user.authTokens.query(on: req).delete().flatMap({ _ in
            return UserPushNotification.deleteAll(userId: userId, conn: req)
        })
    }
    
    static func logout(req: Request, userToken: Token) throws -> Future<HTTPStatus> {
        let userTokenId = try userToken.getId()
        return userToken.delete(on: req).flatMap { _ in
            return UserPushNotification.delete(userTokenId: userTokenId, conn: req)
        }
    }
}
