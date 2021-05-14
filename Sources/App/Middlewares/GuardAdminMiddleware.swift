//
//  GuardAdminMiddleware.swift
//  App
//
//  Created by Amir Hossein on 2/4/19.
//

import Vapor

final class GuardAdminMiddleware : Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        let user = try request.requireAuthenticated(User.self)
        
        guard user.isAdmin else {
            throw Abort(.unauthorizedRequest)
        }
        
        return try next.respond(to: request)
    }
}
