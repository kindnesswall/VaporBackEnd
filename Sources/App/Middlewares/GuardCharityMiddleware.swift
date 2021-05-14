//
//  GuardCharityMiddleware.swift
//  App
//
//  Created by Amir Hossein on 7/6/20.
//

import Vapor


final class GuardCharityMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        let user = try request.auth.require(User.self)
        
        guard user.isCharity else {
            throw Abort(.unauthorizedRequest)
        }
        
        return try next.respond(to: request)
    }
}
