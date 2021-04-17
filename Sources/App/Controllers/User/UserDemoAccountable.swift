//
//  UserDemoAccountable.swift
//  App
//
//  Created by Amir Hossein on 6/5/20.
//

import Foundation
import Vapor

protocol UserDemoAccountable {
    func isDemoAccount(phoneNumber: String) -> Bool
    func validateDemoAccount(phoneNumber: String, activationCode: String) throws -> Bool
}

extension UserDemoAccountable {
    
    func isDemoAccount(phoneNumber: String) -> Bool {
        guard let demoAccount = configuration.demoAccount else { return false }
        return demoAccount.validate(phoneNumber: phoneNumber)
    }
    
    func validateDemoAccount(phoneNumber: String, activationCode: String) throws -> Bool {
        if let demoAccount = configuration.demoAccount,
            isDemoAccount(phoneNumber: phoneNumber) {
            if demoAccount.activationCode == activationCode {
                return true
            } else {
                throw Abort(.invalidActivationCode)
            }
        }
        return false
    }
}
