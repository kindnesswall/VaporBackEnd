//
//  UserProfileController.swift
//  App
//
//  Created by Amir Hossein on 5/27/19.
//

import Vapor


final class UserProfileController {
    
    func show(_ req: Request) throws -> EventLoopFuture<UserProfile> {
        return User.getParameter(on: req).map { user in
            return user.userProfile
        }
    }
    
    func showAuthenticatedUser(_ req: Request) throws -> UserProfile {
        let auth = try req.auth.require(User.self)
        return auth.userProfile
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let auth = try req.auth.require(User.self)
        let userProfile = try req.content.decode(UserProfile.Input.self)
        auth.name = userProfile.name
        auth.image = userProfile.image
        return auth.save(on: req.db)
            .transform(to: .ok)
    }
}
