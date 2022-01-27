//
//  AuthOutput.swift
//  App
//
//  Created by Amir Hossein on 6/15/19.
//

import Vapor

final class AuthOutput : Content {
    let token: Token.Output
    let isAdmin: Bool
    let isCharity: Bool
    
    init(token: Token.Output, isAdmin: Bool, isCharity: Bool) {
        self.token = token
        self.isAdmin = isAdmin
        self.isCharity = isCharity
    }
}

final class AuthAdminAccessOutput : Content {
    
    let activationCode: String
    
    init(activationCode: String) {
        self.activationCode = activationCode
    }
    
}
