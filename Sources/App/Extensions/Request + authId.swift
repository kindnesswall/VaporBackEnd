//
//  Request + authId.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor

extension Request {
    func getAuthId() throws -> Int {
        return try requireAuthenticated(User.self).getId()
    }
}
