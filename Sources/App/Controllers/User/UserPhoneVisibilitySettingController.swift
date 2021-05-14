//
//  UserPhoneVisibilitySettingController.swift
//  App
//
//  Created by Amir Hossein on 5/5/21.
//

import Vapor

final class UserPhoneVisibilitySettingController {
    
    func getOwnerSetting(_ req: Request) throws -> PhoneVisibilitySettingIO {
        let auth = try req.auth.require(User.self)
        return PhoneVisibilitySettingIO(user: auth)
    }
    
    func getUserSetting(_ req: Request) throws -> EventLoopFuture<PhoneVisibilitySettingIO> {
        return User.getParameter(on: req).map { user in
            return PhoneVisibilitySettingIO(user: user)
        }
    }
    
    func set(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let auth = try req.auth.require(User.self)
        let input = try req.content.decode(PhoneVisibilitySettingIO.self)
        return auth.setPhoneVisibility(setting: input.setting, on: req.db)
    }
}
