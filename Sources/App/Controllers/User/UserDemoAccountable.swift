//
//  UserDemoAccountable.swift
//  App
//
//  Created by Amir Hossein on 6/5/20.
//

import Foundation

protocol UserDemoAccountable {
    func isDemoAccount(phoneNumber: String) -> Bool
    func validateDemoAccount(phoneNumber: String, activationCode: String) throws -> Bool
}

extension UserDemoAccountable {
    
    func isDemoAccount(phoneNumber: String) -> Bool {
        let demo = Constants.appInfo.demoAccount
        if demo.phoneNumber == phoneNumber { return true }
        return false
    }
    
    func validateDemoAccount(phoneNumber: String, activationCode: String) throws -> Bool {
        
        if isDemoAccount(phoneNumber: phoneNumber) {
            let demo = Constants.appInfo.demoAccount
            if demo.activationCode == activationCode {
                return true
            } else {
                throw Constants.errors.invalidActivationCode
            }
        }
        return false
    }
}
