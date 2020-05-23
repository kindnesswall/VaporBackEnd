//
//  ApplicationVersionController.swift
//  App
//
//  Created by Amir Hossein on 5/23/20.
//

import Vapor

final class ApplicationVersionController {
    
    func getIOSVersion(_ req: Request) throws -> Future<ApplicationVersion> {
        return ApplicationVersion.get(platform: .iOS, on: req)
    }
    
    func getAndroidVersion(_ req: Request) throws -> Future<ApplicationVersion> {
        return ApplicationVersion.get(platform: .android, on: req)
    }
    
    func setIOSVersion(_ req: Request) throws -> Future<HTTPStatus> {
        return try setVersion(req, platform: .iOS)
    }
    
    func setAndroidVersion(_ req: Request) throws -> Future<HTTPStatus> {
        return try setVersion(req, platform: .android)
    }
    
    private func setVersion(_ req: Request, platform: PlatformType) throws -> Future<HTTPStatus> {
        return try req.content.decode(Inputs.ApplicationVersion.self).flatMap { input in
            return ApplicationVersion.update(platform: platform, input: input, on: req).transform(to: .ok)
        }
    }
}
