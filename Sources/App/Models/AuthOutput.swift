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
    
    init(token: Token, isAdmin: Bool) {
        self.token = token
        self.isAdmin = isAdmin
    }
}
