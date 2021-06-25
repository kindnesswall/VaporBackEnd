//
//  RequestInfo.swift
//  App
//
//  Created by Amir Hossein on 3/13/20.
//

import Vapor
import Fluent

class RequestInfo {
    let req: Request
    let userId: Int
    
    var db: Database { req.db }
    
    init(req: Request, userId: Int) {
        self.req = req
        self.userId = userId
    }
}
