//
//  GuardAdminMiddleware.swift
//  App
//
//  Created by Amir Hossein on 2/4/19.
//

import Vapor

final class GuardAdminMiddleware : Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        
        guard
            let user = request.auth.get(User.self),
            user.isAdmin
            else {
                return request.eventLoop.future(
                    error: Abort(.unauthorizedRequest))
        }
        
        return next.respond(to: request)
    }
}
