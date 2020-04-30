//
//  LogoutController.swift
//  App
//
//  Created by Amir Hossein on 4/30/20.
//

import Vapor

class LogoutController {
    
    func logoutAllDevices(_ req: Request) throws -> Future<HTTPStatus> {

        let auth = try req.requireAuthenticated(User.self)
        return try LogoutController.logoutAllDevices(req: req, user: auth)
    }
    
    static func logoutAllDevices(req: Request, user:User) throws -> Future<HTTPStatus> {
        
        return try user.authTokens.query(on: req).delete().transform(to: .ok)
        
    }
}
