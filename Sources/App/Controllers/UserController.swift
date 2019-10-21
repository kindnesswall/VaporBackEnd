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

final class UserController {
    
    func registerHandler(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.content.decode(Inputs.Login.self).flatMap{ (inputUser)->Future<HTTPStatus> in
            
            let phoneNumber = try UserController.validatePhoneNumber(phoneNumber: inputUser.phoneNumber)
            
            return User.query(on: req, withSoftDeleted: true).filter(\User.phoneNumber == phoneNumber).first().flatMap({ (dBUser) -> Future<HTTPStatus> in
                
                guard dBUser?.deletedAt == nil else {
                    throw Constants.errors.userAccessIsDenied
                }
                
                var user:User
                if let dBUser=dBUser {
                    user = dBUser
                } else {
                    user = User(phoneNumber: phoneNumber)
                }
                
                let activationCode = User.generateActivationCode()
                user.activationCode = activationCode
                self.sendActivationCode(phoneNumber: phoneNumber, activationCode: activationCode)
                return user.save(on: req).transform(to: .ok)
                
            })
        }
    }
    
    
    
    func loginHandler(_ req: Request) throws -> Future<AuthOutput> {
        
        return try req.content.decode(Inputs.Login.self).flatMap{ inputUser in
            
            let phoneNumber = try UserController.validatePhoneNumber(phoneNumber: inputUser.phoneNumber)

            guard let activationCode = inputUser.activationCode else {
                throw Constants.errors.invalidActivationCode
            }

            return User.query(on: req).filter(\User.phoneNumber == phoneNumber).first().flatMap({ user in
                
                guard let user = user else {
                     throw Constants.errors.invalidPhoneNumber
                }
                
                guard user.activationCode == activationCode else {
                    throw Constants.errors.invalidActivationCode
                }
                
                user.activationCode = nil
                return user.save(on: req).flatMap({ user in
                    let token = try Token.generate(for: user)
                    
                    return token.save(on: req).map({ token in
                        return AuthOutput(token: token, isAdmin: user.isAdmin, isCharity: user.isCharity)
                    })
                })
            })
        }
        
        
    }
    
    func adminAccessActivationCode(_ req: Request) throws -> Future<AuthAdminAccessOutput> {
        let auth = try req.requireAuthenticated(User.self)
        
        // Only accessable by admin!
        guard auth.isAdmin else {
            throw Constants.errors.unauthorizedRequest
        }
        
        return try req.content.decode(Inputs.Login.self).flatMap({ inputUser in
            
            let phoneNumber = try UserController.validatePhoneNumber(phoneNumber: inputUser.phoneNumber)
            
            return User.query(on: req).filter(\User.phoneNumber == phoneNumber).first().map({ user in
                
                guard let user = user else {
                    throw Constants.errors.invalidPhoneNumber
                }
                
                guard let activationCode = user.activationCode else {
                    throw Constants.errors.activationCodeNotFound
                }
                
                return AuthAdminAccessOutput(activationCode: activationCode)
            })
            
        })
    }
    
    func changePhoneNumberRequest(_ req: Request) throws -> Future<HTTPStatus> {
        
        let auth = try req.requireAuthenticated(User.self)
        
        return try req.content.decode(Inputs.ChangePhoneNumber.self).flatMap({ input in
            
            let toPhoneNumber = try UserController.validatePhoneNumber(phoneNumber: input.toPhoneNumber)
            
            return User.phoneNumberHasExisted(phoneNumber: toPhoneNumber, conn: req).flatMap({ hasExisted in
                guard !hasExisted else {
                    throw Constants.errors.phoneNumberHasExisted
                }
                
                let activationCode = User.generateActivationCode()
                self.sendActivationCode(phoneNumber: toPhoneNumber, activationCode: activationCode)
                
                let requestedPhoneNumberLog = UserPhoneNumberLog(userId: try auth.getId(), fromPhoneNumber: auth.phoneNumber, toPhoneNumber: toPhoneNumber, status: .requested)
                
                let foundPhoneNumberLog = UserPhoneNumberLog.getLast(phoneNumberLog: requestedPhoneNumberLog, conn: req)
                
                return foundPhoneNumberLog.flatMap({ foundPhoneNumberLog in
                    
                    let phoneNumberLog = foundPhoneNumberLog ?? requestedPhoneNumberLog
                    
                    phoneNumberLog.activationCode = activationCode
                    return phoneNumberLog.save(on:req).transform(to: .ok)
                    
                })
                
            })
            
        })
        
    }
    
    func changePhoneNumberValidate(_ req: Request) throws -> Future<HTTPStatus> {
        
        let auth = try req.requireAuthenticated(User.self)
        
        return try req.content.decode(Inputs.ChangePhoneNumber.self).flatMap({ input in
            
            let toPhoneNumber = try UserController.validatePhoneNumber(phoneNumber: input.toPhoneNumber)
            
            return User.phoneNumberHasExisted(phoneNumber: toPhoneNumber, conn: req).flatMap({ hasExisted in
                guard !hasExisted else {
                    throw Constants.errors.phoneNumberHasExisted
                }
                
                let requestedPhoneNumberLog = UserPhoneNumberLog(userId: try auth.getId(), fromPhoneNumber: auth.phoneNumber, toPhoneNumber: toPhoneNumber, status: .requested)
                
                let phoneNumberLog = UserPhoneNumberLog.getLast(phoneNumberLog: requestedPhoneNumberLog, conn: req)
                
                return phoneNumberLog.flatMap({ phoneNumberLog in
                    guard let phoneNumberLog = phoneNumberLog else {
                        throw Constants.errors.invalidPhoneNumber
                    }
                    
                    guard let activationCode = input.activationCode,
                        phoneNumberLog.activationCode == activationCode
                        else { throw Constants.errors.invalidActivationCode }
                    
                    auth.phoneNumber = toPhoneNumber
                    return auth.save(on: req).flatMap({ _ in
                        
                        phoneNumberLog.activationCode = nil
                        phoneNumberLog.setStatus(status: .completed)
                        
                        return phoneNumberLog.save(on: req).flatMap({ _ in
                            return try UserController.logoutAllDevices(req: req, user: auth)
                        })
                    })
                    
                })
                
            })
            
        })
        
    } 
    
    private func sendActivationCode(phoneNumber:String,activationCode:String){
        print("User Activation Code: \(activationCode)") //
//        self.sendActivationCodeSMS(phoneNumber: phoneNumber, activationCode: activationCode)
    }
    
    private func sendActivationCodeSMS(phoneNumber:String,activationCode:String){
        guard let url = URIs().getSMSUrl(apiKey: Constants.appInfo.smsConfig.apiKey, receptor: phoneNumber, template: Constants.appInfo.smsConfig.activationCodeTemplate, token: activationCode) else {
            return
        }
        
        APICall.request(url: url, httpMethod: .POST) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    func logoutAllDevices(_ req: Request) throws -> Future<HTTPStatus> {

        let auth = try req.requireAuthenticated(User.self)
        return try UserController.logoutAllDevices(req: req, user: auth)
    }
    
    static func logoutAllDevices(req: Request, user:User) throws -> Future<HTTPStatus> {
        
        return try user.authTokens.query(on: req).delete().transform(to: .ok)
        
    }
    
    private static func validatePhoneNumber(phoneNumber:String) throws -> String {
        guard
        phoneNumber.isCorrectPhoneNumber(),
        let phoneNumber = phoneNumber.castNumberToEnglish()
        else { throw Constants.errors.invalidPhoneNumber }
        return phoneNumber
    }
}
