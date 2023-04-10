//
//  Request + authId.swift
//  App
//
//  Created by Amir Hossein on 8/31/20.
//

import Vapor

extension Request {
    func requireAuthID() throws -> Int {
        return try auth.require(User.self).requireID()
    }
}
