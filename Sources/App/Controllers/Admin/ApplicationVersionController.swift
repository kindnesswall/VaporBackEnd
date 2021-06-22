//
//  ApplicationVersionController.swift
//  App
//
//  Created by Amir Hossein on 5/23/20.
//

import Vapor

final class ApplicationVersionController {
    
    func getIOSVersion(_ req: Request) throws -> EventLoopFuture<ApplicationVersion> {
        return ApplicationVersion.get(platform: .iOS, on: req.db)
    }
    
    func getAndroidVersion(_ req: Request) throws -> EventLoopFuture<ApplicationVersion> {
        return ApplicationVersion.get(platform: .android, on: req.db)
    }
    
    func setIOSVersion(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try setVersion(req, platform: .iOS)
    }
    
    func setAndroidVersion(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try setVersion(req, platform: .android)
    }
    
    private func setVersion(_ req: Request, platform: PlatformType) throws -> EventLoopFuture<HTTPStatus> {
        
        let input = try req.content.decode(Inputs.ApplicationVersion.self)
        return ApplicationVersion
            .update(
                platform: platform,
                input: input,
                on: req.db)
            .transform(to: .ok)
    }
}
