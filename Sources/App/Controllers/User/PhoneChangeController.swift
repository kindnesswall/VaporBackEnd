//
//  PhoneChangeController.swift
//  App
//
//  Created by Amir Hossein on 4/24/20.
//

import Vapor

final class PhoneChangeController: PhoneNumberValidator {
    func changePhoneNumberRequest(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let auth = try req.auth.require(User.self)
        let input = try req.content.decode(Inputs.ChangePhoneNumber.self)
        
        let toPhoneNumber = try self.validate(phoneNumber: input.toPhoneNumber)
        
        return User.phoneNumberHasExisted(
            phoneNumber: toPhoneNumber,
            conn: req.db).flatMap { hasExisted in
                guard !hasExisted else {
                    return req.db.makeFailedFuture(
                        .phoneNumberHasExisted)
                }
                
                let activationCode = UserPhoneNumberLog
                    .ActivationCode
                    .generate()
                
                let output = UserPhoneNumberLog.setActivationCode(
                    req: req,
                    auth: auth,
                    toPhoneNumber: toPhoneNumber,
                    activationCode: activationCode)
                
                return output.flatMap { _ in
                    
                    let template: SMSTemplatesType = .register
                    return SMSController.send(
                        phoneNumber: auth.phoneNumber,
                        code: activationCode.from,
                        template: template,
                        on: req).flatMap { _ in
                            return SMSController.send(
                                phoneNumber: toPhoneNumber,
                                code: activationCode.to,
                                template: template,
                                on: req)
                    }
                }
        }
    }
    
    func changePhoneNumberValidate(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let auth = try req.auth.require(User.self)
        let input = try req.content.decode(Inputs.ChangePhoneNumber.self)
        
        let toPhoneNumber = try self.validate(phoneNumber: input.toPhoneNumber)
        
        guard let activationCode = UserPhoneNumberLog.ActivationCode(from: input.activationCode_from, to: input.activationCode_to) else {
            throw Abort(.invalidActivationCode)
        }
        
        return User.phoneNumberHasExisted(
            phoneNumber: toPhoneNumber,
            conn: req.db).flatMap { hasExisted in
                guard !hasExisted else {
                    return req.db.makeFailedFuture(
                        .phoneNumberHasExisted)
                }
                
                return UserPhoneNumberLog.check(
                    req: req,
                    auth: auth,
                    toPhoneNumber: toPhoneNumber,
                    activationCode: activationCode)
                    .flatMap { phoneNumberLog in
                        
                        return auth.change(
                            toPhoneNumber: toPhoneNumber,
                            on: req.db).flatMap { _ in
                                return phoneNumberLog.complete(on: req.db)
                                    .flatMap { _ in
                                        return LogoutController.logoutAllDevices(req: req, user: auth)
                                }
                        }
                }
        }
    }
}

