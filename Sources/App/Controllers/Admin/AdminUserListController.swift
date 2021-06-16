//
//  AdminUserListController.swift
//  App
//
//  Created by Amir Hossein on 6/30/20.
//

import Vapor

final class AdminUserListController {
    
    func userAllowAccess(_ req: Request) throws -> EventLoopFuture<User> {
        let db = req.db
        let input = try req.content.decode(UserAllowAccessInput.self)
        return User.findOrFail(input.userId, withSoftDeleted: true, on: db).flatMap { user in
            return user.restore(on: db).transform(to: user)
        }
        
    }
    func userDenyAccess(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return User.getParameter(on: req).flatMap({ user in
            return user.delete(on: req.db).flatMap({ _ in
                return try LogoutController.logoutAllDevices(req: req, user: user)
            })
        })
    }
    
    func usersActiveList(_ req: Request) throws -> EventLoopFuture<[User]> {
        let queryParam = try req.content.decode(Inputs.UserQuery.self)
        return User.allActiveUsers(on: req.db, queryParam: queryParam)
    }
    
    func usersBlockedList(_ req: Request) throws -> EventLoopFuture<[User]> {
        let queryParam = try req.content.decode(Inputs.UserQuery.self)
        return User.allBlockedUsers(on: req.db, queryParam: queryParam)
    }
    
    func usersChatBlockedList(_ req: Request) throws -> EventLoopFuture<[User_BlockedReport]> {
        return User.allChatBlockedUsers(on: req.db)
    }
}
