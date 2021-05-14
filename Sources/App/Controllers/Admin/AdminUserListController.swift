//
//  AdminUserListController.swift
//  App
//
//  Created by Amir Hossein on 6/30/20.
//

import Vapor

final class AdminUserListController {
    
    func userAllowAccess(_ req: Request) throws -> EventLoopFuture<User> {
        return try req.content.decode(UserAllowAccessInput.self).flatMap { input in
            
            return User.get(input.userId, withSoftDeleted: true, on: req).flatMap { user in
                return user.restore(on: req)
            }
        }
    }
    func userDenyAccess(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap({ user in
            return user.delete(on: req).flatMap({ _ in
                return try LogoutController.logoutAllDevices(req: req, user: user)
            })
        })
    }
    
    func usersActiveList(_ req: Request) throws -> EventLoopFuture<[User]> {
        
        return try req.content.decode(Inputs.UserQuery.self).flatMap { queryParam in
            return User.allActiveUsers(on: req, queryParam: queryParam)
        }
    }
    
    func usersBlockedList(_ req: Request) throws -> EventLoopFuture<[User]> {
        return try req.content.decode(Inputs.UserQuery.self).flatMap { queryParam in
            return User.allBlockedUsers(on: req, queryParam: queryParam)
        }
    }
    
    func usersChatBlockedList(_ req: Request) throws -> EventLoopFuture<[User_BlockedReport]> {
        return User.allChatBlockedUsers(on: req)
    }
}
