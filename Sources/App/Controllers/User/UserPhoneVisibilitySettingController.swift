//
//  UserPhoneVisibilitySettingController.swift
//  App
//
//  Created by Amir Hossein on 5/5/21.
//

import Vapor

final class UserPhoneVisibilitySettingController {
    
    func getOwnerSetting(_ req: Request) throws -> Future<PhoneVisibilitySettingIO> {
        let auth = try req.requireAuthenticated(User.self)
        return req.future(PhoneVisibilitySettingIO(user: auth))
    }
    
    func getUserSetting(_ req: Request) throws -> Future<PhoneVisibilitySettingIO> {
        let userId = try req.parameters.next(Int.self)
        return User.get(userId, on: req).map { user in
            return PhoneVisibilitySettingIO(user: user)
        }
    }
    
    func set(_ req: Request) throws -> Future<HTTPStatus> {
        let auth = try req.requireAuthenticated(User.self)
        let input = try req.content.decode(PhoneVisibilitySettingIO.self)
        return input.flatMap { input in
            return auth.setPhoneVisibility(setting: input.setting, on: req)
        }
    }
}
