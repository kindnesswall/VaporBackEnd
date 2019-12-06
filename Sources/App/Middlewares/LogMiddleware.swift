//
//  LogMiddleware.swift
//  App
//
//  Created by Amir Hossein on 12/6/19.
//

import Vapor

final class LogMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        let log = getLog(request: request)
        let lastLog = try? String(contentsOf: filePath, encoding: .utf8)
        let newLog = "\(lastLog ?? "")\(log)"
        save(log: newLog)
        
        return try next.respond(to: request)
    }
    
    private func getLog(request: Request) -> String {
        
        let method = request.http.method
        let url = request.http.url
        let time = Date().description
        let ip = request.http.remotePeer.hostname ?? ""
        let user = try? request.requireAuthenticated(User.self)
        let userId = user?.id?.description ?? "Guest"
        
        let log = "\(method) \(url):    \(time)    ip: \(ip)   user: \(userId)\n"
        return log
    }
    
    private func save(log: String) {
        guard let logData = log.data(using: .utf8) else {
            return
        }
        let fileManager = AppFileManager()
        try? fileManager.createDirectoryIfDoesNotExist(path: directoryPath)
        fileManager.saveFile(path: filePath, data: logData)
    }
    
    private var directoryPath: URL {
        let appInfo = Constants.appInfo
        let path = "\(appInfo.rootPath)\(appInfo.logPath)"
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    private var filePath: URL {
        let fileName = Constants.appInfo.logName
        let url = directoryPath.appendingPathComponent(fileName)
        return url
    }
    
}
