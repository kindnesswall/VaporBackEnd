//
//  CustomFutureList.swift
//  App
//
//  Created by Amir Hossein on 7/13/19.
//

import Vapor

class CustomFutureList<T> {
    private var results = [T?]()
    private let promise:Promise<[T]>
    private let futures: [EventLoopFuture<T>]
    
    init(req:Request, futures: [EventLoopFuture<T>]) {
        self.promise = req.eventLoop.newPromise([T].self)
        self.futures = futures
        self.setFutures()
    }
    
    deinit {
//        print("deinit")
    }
    
    func futureResult()->EventLoopFuture<[T]>{
        return promise.futureResult
    }
    
    private func setFutures(){
        
        guard futures.count != 0 else {
            promise.succeed(result: [])
            return
        }
        
        for future in futures {
            future.map {value in
                self.arrived(value)
            }.catch {error in
                self.arrived(nil, error: error)
            }
        }
    }
    
    func arrived(_ value: T?, error: Error? = nil) {
        self.results.append(value)
        if self.results.count == futures.count {
            promise.succeed(result: self.results.compactMap({ $0 }))
        }
    }
}
