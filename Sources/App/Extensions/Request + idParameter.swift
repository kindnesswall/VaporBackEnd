//
//  Request + idParameter.swift
//  
//
//  Created by Amir Hossein on 6/12/21.
//

import Vapor

extension Request {
    var idParameter: Int? { parameters.get("id") }
    func requireIDParameter() throws -> Int { try parameters.require("id") }
}

