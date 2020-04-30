//
//  PhoneChangeController.swift
//  App
//
//  Created by Amir Hossein on 4/24/20.
//

import Vapor

final class PhoneChangeController: UserControllerCore {
    func changePhoneNumberRequest(_ req: Request) throws -> Future<HTTPStatus> {
        
        let auth = try req.requireAuthenticated(User.self)
        
        return try req.content.decode(Inputs.ChangePhoneNumber.self).flatMap({ input in
            
            let toPhoneNumber = try UserController.validatePhoneNumber(phoneNumber: input.toPhoneNumber)
            
            return User.phoneNumberHasExisted(phoneNumber: toPhoneNumber, conn: req).flatMap({ hasExisted in
                guard !hasExisted else {
                    throw Constants.errors.phoneNumberHasExisted
                }
                
                let activationCode = UserPhoneNumberLog.ActivationCode.generate()
                
                let output = try UserPhoneNumberLog.setActivationCode(req: req, auth: auth, toPhoneNumber: toPhoneNumber, activationCode: activationCode)
                
                return output.flatMap { _ in
                    
                    let template: SMSTemplates = .register
                    return try SMSController.send(phoneNumber: auth.phoneNumber, code: activationCode.from, template: template, on: req).flatMap { _ in
                        return try SMSController.send(phoneNumber: toPhoneNumber, code: activationCode.to, template: template, on: req)
                    }
                    
                }
                
            })
            
        })
        
    }
    
    func changePhoneNumberValidate(_ req: Request) throws -> Future<HTTPStatus> {
        
        let auth = try req.requireAuthenticated(User.self)
        
        return try req.content.decode(Inputs.ChangePhoneNumber.self).flatMap({ input in
            
            let toPhoneNumber = try UserController.validatePhoneNumber(phoneNumber: input.toPhoneNumber)
            
            guard let activationCode = UserPhoneNumberLog.ActivationCode(from: input.activationCode_from, to: input.activationCode_to) else {
                throw Constants.errors.activationCodesNotFound
            }
            
            return User.phoneNumberHasExisted(phoneNumber: toPhoneNumber, conn: req).flatMap({ hasExisted in
                guard !hasExisted else {
                    throw Constants.errors.phoneNumberHasExisted
                }
                
                return try UserPhoneNumberLog.check(req: req, auth: auth, toPhoneNumber: toPhoneNumber, activationCode: activationCode).flatMap { phoneNumberLog in
                    
                    return auth.change(toPhoneNumber: toPhoneNumber, on: req).flatMap({ _ in
                        return phoneNumberLog.complete(on: req).flatMap { _ in
                            return try UserController.logoutAllDevices(req: req, user: auth)
                        }
                    })
                }
                
            })
            
        })
    }
}

