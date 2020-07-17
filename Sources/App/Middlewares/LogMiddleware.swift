//
//  LogMiddleware.swift
//  App
//
//  Created by Amir Hossein on 12/6/19.
//

import Vapor

final class LogMiddleware: Middleware {
    
    let logDirectory = LogDirectory()
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        let log = getLog(request: request)
        try? log.appendToURL(fileURL: logDirectory.filePath)
        
        return try next.respond(to: request)
    }
    
    private func getLog(request: Request) -> String {
        
        let method = request.http.method
        let url = request.http.url
        let time = Date().description
        let ip = request.http.remotePeer.hostname ?? ""
        let user = try? request.requireAuthenticated(User.self)
        let userId = user?.id?.description ?? "Guest"
        let spacer = "    "
        
        let log = "\(method) \(url)\(spacer)\(time)\(spacer)ip: \(ip)\(spacer)user: \(userId)\n"
        return log
    }
    
}
