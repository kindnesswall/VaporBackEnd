//
//  UserController.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Foundation

import Vapor
import Fluent
import FluentPostgresDriver
import Crypto

final class UserController: UserControllerCore, PhoneNumberValidator {
    
    func registerHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let inputUser = try req.content.decode(Inputs.Login.self)
        
        let phoneNumber = try self.validate(phoneNumber: inputUser.phoneNumber)
        
        if self.isDemoAccount(phoneNumber: phoneNumber) {
            return req.db.makeSucceededFuture(.ok)
        }
        
        let activationCode = User.generateActivationCode()
        
        return self.setActvatioCode(
            req: req,
            phoneNumber: phoneNumber,
            activationCode: activationCode)
            .flatMap { _ in
                return SMSController.send(
                    phoneNumber: phoneNumber,
                    code: activationCode,
                    template: .register,
                    on: req)
        }
    }
    
    
    
    func loginHandler(_ req: Request) throws -> EventLoopFuture<AuthOutput> {
        
        let inputUser = try req.content.decode(Inputs.Login.self)
        
        let phoneNumber = try self.validate(phoneNumber: inputUser.phoneNumber)
        
        guard let activationCode = inputUser.activationCode else {
            throw Abort(.invalidActivationCode)
        }
        
        return try self.checkActivationCode(
            req: req,
            phoneNumber: phoneNumber,
            activationCode: activationCode)
            .flatMap { _ in
                return self.findOrCreateUser(
                    req: req,
                    phoneNumber: phoneNumber)
                    .flatMap { user in
                        return self.getToken(req: req, user: user)
                }
        }
        
    }
    
    // Only for development purpose
    func adminAccessActivationCode(_ req: Request) throws -> EventLoopFuture<AuthAdminAccessOutput> {
        let auth = try req.auth.require(User.self)
        
        // Only accessable by admin!
        guard auth.isAdmin else {
            throw Abort(.unauthorizedRequest)
        }
        
        let inputUser = try req.content.decode(Inputs.Login.self)
        let phoneNumber = try self.validate(phoneNumber: inputUser.phoneNumber)
        
        return PhoneNumberActivationCode.find(
            req: req,
            phoneNumber: phoneNumber)
            .flatMapThrowing { item in
                
                guard let item = item else {
                    throw Abort(.invalidPhoneNumber)
                }
                
                guard let activationCode = item.activationCode else {
                    throw Abort(.activationCodeNotFound)
                }
                
                return AuthAdminAccessOutput(activationCode: activationCode)
        }
        
    }
    
}
