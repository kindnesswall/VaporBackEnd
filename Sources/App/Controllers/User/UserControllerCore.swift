//
//  UserControllerCore.swift
//  App
//
//  Created by Amir Hossein on 11/5/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

class UserControllerCore: UserDemoAccountable {
    
    func findOrCreateUser(req: Request, phoneNumber: String) -> EventLoopFuture<User> {
        
        return User.find(
            req: req,
            phoneNumber: phoneNumber)
            .flatMap { foundUser in
                
                if let foundUser = foundUser {
                    return req.db.makeSucceededFuture(foundUser)
                }
                
                let user = User(phoneNumber: phoneNumber)
                return user
                    .save(on: req.db)
                    .transform(to: user)
            }
    }
    
    func setActvatioCode(req: Request, phoneNumber: String, activationCode: String) -> EventLoopFuture<HTTPStatus> {
        return User.isNotDeleted(
            req: req,
            phoneNumber: phoneNumber)
            .flatMap { _ in
                
                return PhoneNumberActivationCode.find(
                    req: req,
                    phoneNumber: phoneNumber).flatMap { foundItem in
                        
                        let item = self.setActvatioCode(
                            req: req,
                            foundItem: foundItem,
                            phoneNumber: phoneNumber,
                            activationCode: activationCode)
                        
                        return item.save(on: req.db)
                            .transform(to: .ok)
                }
        }
    }
    
    private func setActvatioCode(req: Request, foundItem: PhoneNumberActivationCode?, phoneNumber: String, activationCode: String) -> PhoneNumberActivationCode {
        
        if let foundItem = foundItem {
            foundItem.activationCode = activationCode
            return foundItem
        }
        
        let item = PhoneNumberActivationCode(
            phoneNumber: phoneNumber,
            activationCode: activationCode)
        return item
    }
    
    
    func checkActivationCode(req: Request, phoneNumber: String, activationCode: String) throws -> EventLoopFuture<HTTPStatus> {
        
        if try validateDemoAccount(
            phoneNumber: phoneNumber,
            activationCode: activationCode) {
            return req.db.makeSucceededFuture(.ok)
        }
        
        return PhoneNumberActivationCode.check(
            req: req,
            phoneNumber: phoneNumber,
            activationCode: activationCode)
    }
    
    func getToken(req: Request, user: User) -> EventLoopFuture<AuthOutput> {
        
        guard let userId = user.id else {
            return req.db.makeFailedFuture(.nilUserId)
        }
        
        let token = Token.generate(for: userId)
        
        return token.save(on: req.db)
            .map {
                return AuthOutput(
                    token: token,
                    isAdmin: user.isAdmin,
                    isCharity: user.isCharity)
        }
    }    
}
