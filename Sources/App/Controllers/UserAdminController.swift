//
//  UserAdminController.swift
//  App
//
//  Created by Amir Hossein on 4/5/19.
//

import Vapor
import FluentPostgreSQL

final class UserAdminController {
    func userAllowAccess(_ req: Request) throws -> Future<User> {
        return try req.content.decode(UserAllowAccessInput.self).flatMap({ input in
            return User.query(on: req, withSoftDeleted: true).filter(\.id == input.userId).first().flatMap({ user in
                guard let user = user else {
                    throw Constants.errors.wrongUserId
                }
                return user.restore(on: req)
            })
        })
    }
    
    func userDenyAccess(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap({ user in
            return user.delete(on: req)
        }).transform(to: .ok)
    }
}
