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
        
        return try req.content.decode(User.Input.self).flatMap{ (inputUser)->Future<HTTPStatus> in
            
            let phoneNumber = try UserController.checkPhoneNumber(inputUser: inputUser)
            
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
                print("User Activation Code: \(activationCode)") //
//                self.sendActivationCodeSMS(phoneNumber: phoneNumber, activationCode: activationCode)
                return user.save(on: req).transform(to: .ok)
                
            })
        }
    }
    
    
    
    func loginHandler(_ req: Request) throws -> Future<AuthOutput> {
        
        return try req.content.decode(User.Input.self).flatMap{ inputUser in
            
            let phoneNumber = try UserController.checkPhoneNumber(inputUser: inputUser)

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
                        return AuthOutput(token: token, isAdmin: user.isAdmin)
                    })
                })
            })
        }
        
        
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
    
    private static func checkPhoneNumber(inputUser:User.Input) throws -> String {
        guard inputUser.phoneNumber.isCorrectPhoneNumber(),
            let phoneNumber = inputUser.phoneNumber.castNumberToEnglish()  else {
                throw Constants.errors.invalidPhoneNumber
        }
        return phoneNumber
    }
}
