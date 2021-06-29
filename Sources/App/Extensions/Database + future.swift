//
//  Database + future.swift
//  
//
//  Created by Amir Hossein on 5/31/21.
//

import Vapor
import Fluent

extension Database {
    func makeSucceededFuture<Success>(_ value: Success) -> EventLoopFuture<Success> {
        return eventLoop.makeSucceededFuture(value)
    }
    
    func makeFailedFuture<T>(_ error: ErrorType) -> EventLoopFuture<T> {
        return makeFailedFuture(Abort(error))
    }
    
    func makeFailedFuture<T>(_ error: Error) -> EventLoopFuture<T> {
        return eventLoop.makeFailedFuture(error)
    }
    
}
