//
//  UserProfileController.swift
//  App
//
//  Created by Amir Hossein on 5/27/19.
//

import Vapor


final class UserProfileController {
    
    func show(_ req: Request) throws -> Future<UserProfile> {
        return try req.parameters.next(User.self).map({ user in
            let userProfile = UserProfile(name: user.name, image: user.image)
            return userProfile
        })
    }
 
    func update(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        
        return try req.content.decode(UserProfile.self).flatMap({ (userProfile) -> Future<User>  in
            user.name = userProfile.name
            user.image = userProfile.image
            
            return user.save(on: req)
        }).transform(to: .ok)
        
    }
    
    
    
}
