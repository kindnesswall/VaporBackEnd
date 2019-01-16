//
//  UserController.swift
//  App
//
//  Created by Amir Hossein on 1/15/19.
//

import Foundation

import Vapor
import Crypto

final class UserController {
    
    func createHandler(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap(to: User.self){ (user) in
            guard user.phoneNumber.isCorrectPhoneNumber(),
                let phoneNumber = user.phoneNumber.castNumberToEnglish()  else {
                throw Constants.errors.invalidPhoneNumber
            }
            user.phoneNumber = phoneNumber
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req)
            }.flatMap(to: Token.self) { user in
                let token = try Token.generate(for: user)
                return token.save(on: req)
            }
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}
