//
//  UserPhoneVisibilitySettingController.swift
//  App
//
//  Created by Amir Hossein on 5/5/21.
//

import Vapor

final class UserPhoneVisibilitySettingController {
    
    func get(_ req: Request) throws -> EventLoopFuture<PhoneVisibilitySettingIO> {
        let auth = try req.auth.require(User.self)
        let output = PhoneVisibilitySettingIO(setting: auth.phoneVisibilitySetting)
        return req.future(output)
    }
    
    func set(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let auth = try req.auth.require(User.self)
        let input = try req.content.decode(PhoneVisibilitySettingIO.self)
        return input.flatMap { input in
            return auth.setPhoneVisibility(setting: input.setting, on: req)
        }
    }
}
