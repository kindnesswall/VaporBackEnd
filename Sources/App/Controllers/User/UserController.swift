//
//  UserController.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Foundation

import Vapor
import FluentPostgreSQL
import Crypto

final class UserController: UserControllerCore, PhoneNumberValidator {
    
    func registerHandler(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.content.decode(Inputs.Login.self).flatMap{ (inputUser)->Future<HTTPStatus> in
            
            let phoneNumber = try self.validate(phoneNumber: inputUser.phoneNumber)
            
            if self.isDemoAccount(phoneNumber: phoneNumber) {
                return req.future(.ok)
            }
            
            let activationCode = User.generateActivationCode()
            
            return self.setActvatioCode(req: req, phoneNumber: phoneNumber, activationCode: activationCode).flatMap { _ in
                return try SMSController.send(phoneNumber: phoneNumber, code: activationCode, template: .register, on: req)
            }
        }
    }
    
    
    
    func loginHandler(_ req: Request) throws -> Future<AuthOutput> {
        
        return try req.content.decode(Inputs.Login.self).flatMap{ inputUser in
            
            let phoneNumber = try self.validate(phoneNumber: inputUser.phoneNumber)

            guard let activationCode = inputUser.activationCode else {
                throw Abort(.invalidActivationCode)
            }
            
            return try self.checkActivationCode(req: req, phoneNumber: phoneNumber, activationCode: activationCode).flatMap { _ in
                
                return self.findOrCreateUser(req: req, phoneNumber: phoneNumber).flatMap { user in
                    return try self.getToken(req: req, user: user)
                }
            }
        }
    }
    
    // Only for development purpose
    func adminAccessActivationCode(_ req: Request) throws -> Future<AuthAdminAccessOutput> {
        let auth = try req.requireAuthenticated(User.self)
        
        // Only accessable by admin!
        guard auth.isAdmin else {
            throw Abort(.unauthorizedRequest)
        }
        
        return try req.content.decode(Inputs.Login.self).flatMap({ inputUser in
            
            let phoneNumber = try self.validate(phoneNumber: inputUser.phoneNumber)
            
            return PhoneNumberActivationCode.find(req: req, phoneNumber: phoneNumber).map { item in
                
                guard let item = item else {
                    throw Abort(.invalidPhoneNumber)
                }
                
                guard let activationCode = item.activationCode else {
                    throw Abort(.activationCodeNotFound)
                }
                
                return AuthAdminAccessOutput(activationCode: activationCode)
            }
        })
    }
    
}
