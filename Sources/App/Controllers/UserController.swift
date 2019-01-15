//
//  UserController.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Foundation

import Vapor
import Crypto

final class UserController {
    
    func createHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(User.self).flatMap(to: User.self){ (user) in
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req)
            }.transform(to: .ok)
    }
}
