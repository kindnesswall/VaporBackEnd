//
//  UserProfileController.swift
//  App
//
//  Created by Amir Hossein on 5/27/19.
//

import Vapor


final class UserProfileController {
    
    func show(_ req: Request) throws -> EventLoopFuture<UserProfile> {
        return User.getParameter(on: req).flatMapThrowing { user in
            return try user.userProfile(req: req)
        }
    }
 
    func update(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        
        return try req.content.decode(UserProfile.Input.self).flatMap({ (userProfile) -> EventLoopFuture<User>  in
            user.name = userProfile.name
            user.image = userProfile.image
            
            return user.save(on: req)
        }).transform(to: .ok)
        
    }
    
    
    
}
