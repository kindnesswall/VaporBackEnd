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
            
            return User.query(on: req).filter(\User.phoneNumber == phoneNumber).first().flatMap({ (dBUser) -> Future<HTTPStatus> in
                
                var user:User
                if let dBUser=dBUser {
                    user = dBUser
                } else {
                    user = User(phoneNumber: phoneNumber)
                }
                
                user.activationCode = try User.generateActivationCode()
                print("User Activation Code: \(user.activationCode ?? "")") ////
                return user.save(on: req).transform(to: .ok)
                
            })
        }
    }
    
    
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        
        return try req.content.decode(User.Input.self).flatMap{ (inputUser)->Future<Token> in
            
            let phoneNumber = try UserController.checkPhoneNumber(inputUser: inputUser)

            guard let activationCode = inputUser.activationCode else {
                throw Constants.errors.invalidActivationCode
            }

            return User.query(on: req).filter(\User.phoneNumber == phoneNumber).first().flatMap({ (user) -> Future<Token> in
                
                guard let user = user else {
                     throw Constants.errors.invalidPhoneNumber
                }
                
                guard user.activationCode == activationCode else {
                    throw Constants.errors.invalidActivationCode
                }
                
                user.activationCode = nil
                user.save(on: req).catch(AppErrorCatch.printError)
                
                let token = try Token.generate(for: user)
                return token.save(on: req)

            })
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
