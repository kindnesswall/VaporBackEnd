//
//  GuardCharityMiddleware.swift
//  App
//
//  Created by Amir Hossein on 7/6/20.
//

import Vapor

final class GuardCharityMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        
        guard
            let user = request.auth.get(User.self),
            user.isCharity
            else {
                return request.eventLoop.future(
                    error: Abort(.unauthorizedRequest))
        }
        
        return next.respond(to: request)
    }
}
