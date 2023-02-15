//
//  UserControllerCore.swift
//  App
//
//  Created by Amir Hossein on 11/5/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

class UserControllerCore: UserDemoAccountable, PushRegisterable {
    
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
            foundItem.set(activationCode: activationCode)
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
    
    func generateTokenAndRegisterPush(
        user: User,
        inputPushNotification: Inputs.UserPushNotification?,
        on db: Database) -> EventLoopFuture<AuthOutput>
    {
        guard let userId = user.id else {
            return db.makeFailedFuture(.nilUserId)
        }
        return generateToken(for: userId, on: db).flatMap { token in
            
            let output = AuthOutput(
                token: token.outputObject,
                isAdmin: user.isAdmin,
                isCharity: user.isCharity)
            
            if let inputPushNotification = inputPushNotification {
                return self.registerPush(userId: userId,
                                    userToken: token,
                                    input: inputPushNotification,
                                    on: db)
                .transform(to: output)
            } else {
                return db.makeSucceededFuture(output)
            }
        }
    }
    
    func generateToken(for userId: Int, on db: Database) -> EventLoopFuture<Token> {
        let token = Token.generate(for: userId)
        return token
            .create(on: db)
            .transform(to: token)
    }
}
