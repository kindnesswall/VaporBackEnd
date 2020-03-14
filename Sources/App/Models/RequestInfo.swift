//
//  RequestInfo.swift
//  App
//
//  Created by Amir Hossein on 3/13/20.
//

import Vapor

class RequestInfo {
    let req: Request
    let userId: Int
    
    init(req: Request, userId: Int) {
        self.req = req
        self.userId = userId
    }
}
