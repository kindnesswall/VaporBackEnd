//
//  LogoutController.swift
//  App
//
//  Created by Amir Hossein on 4/30/20.
//

import Vapor

class LogoutController {
    
    func logout(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authToken = try req.auth.require(Token.self)
        return try LogoutController.logout(req: req, userToken: authToken)
    }
    
    func logoutAllDevices(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {

        let auth = try req.auth.require(User.self)
        return LogoutController.logoutAllDevices(req: req, user: auth)
    }
    
    static func logoutAllDevices(req: Request, user:User) -> EventLoopFuture<HTTPStatus> {
        
        guard let userId = user.id else {
            return req.db.makeFailedFuture(.nilUserId)
        }
        
        return user
            .$authTokens
            .query(on: req.db)
            .delete()
            .flatMap { _ in
                return UserPushNotification.deleteAll(
                    userId: userId,
                    conn: req.db)
            }
    }
    
    static func logout(req: Request, userToken: Token) throws -> EventLoopFuture<HTTPStatus> {
        let userTokenId = try userToken.getId()
        return userToken.delete(on: req.db).flatMap { _ in
            return UserPushNotification.delete(userTokenId: userTokenId, conn: req.db)
        }
    }
}
