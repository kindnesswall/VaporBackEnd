//
//  UserControllerCore.swift
//  App
//
//  Created by Amir Hossein on 11/5/19.
//

import Vapor
import FluentPostgreSQL

class UserControllerCore {
    func findOrCreateUser(req: Request, phoneNumber: String) -> Future<User> {
        
        return User.find(req: req, phoneNumber: phoneNumber).flatMap { foundUser in
            
            let user = foundUser ?? User(phoneNumber: phoneNumber)
            return user.save(on: req)
        }
    }
    
    func setActvatioCode(req: Request, phoneNumber: String, activationCode: String) -> Future<HTTPStatus> {
        return User.isNotDeleted(req: req, phoneNumber: phoneNumber).flatMap { _ in
            
            return PhoneNumberActivationCode.find(req: req, phoneNumber: phoneNumber).flatMap { foundItem in
                
                let item = self.setActvatioCode(req: req, foundItem: foundItem, phoneNumber: phoneNumber, activationCode: activationCode)
                
                return item.save(on: req).transform(to: .ok)
            }
        }
    }
    
    private func setActvatioCode(req: Request, foundItem: PhoneNumberActivationCode?, phoneNumber: String, activationCode: String) -> PhoneNumberActivationCode {
        
        if let foundItem = foundItem {
            foundItem.activationCode = activationCode
            return foundItem
        }
        
        let item = PhoneNumberActivationCode(phoneNumber: phoneNumber, activationCode: activationCode)
        return item
    }
    
    
    func checkActivationCode(req: Request, phoneNumber: String, activationCode: String) -> Future<HTTPStatus> {
        
        return PhoneNumberActivationCode.check(req: req, phoneNumber: phoneNumber, activationCode: activationCode)
    }
    
    func getToken(req: Request, user: User) throws -> Future<AuthOutput> {
        let token = try Token.generate(for: user)
        
        return token.save(on: req).map({ token in
            return AuthOutput(token: token, isAdmin: user.isAdmin, isCharity: user.isCharity)
        })
    }
    
}
