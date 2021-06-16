//
//  Model + getParameter.swift
//  
//
//  Created by Amir Hossein on 6/12/21.
//

import Vapor
import Fluent

extension Model where IDValue == Int {
    static func getParameter(on req: Request) -> EventLoopFuture<Self> {
        return findOrFail(req.idParameter, on: req.db)
    }
}
