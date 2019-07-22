//
//  AuthOutput.swift
//  App
//
//  Created by Amir Hossein on 6/15/19.
//

import Vapor

final class AuthOutput : Content {
    let token: Token
    let isAdmin: Bool
    let isCharity: Bool
    
    init(token: Token, isAdmin: Bool, isCharity: Bool) {
        self.token = token
        self.isAdmin = isAdmin
        self.isCharity = isCharity
    }
}
