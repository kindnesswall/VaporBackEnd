//
//  CustomFutureList.swift
//  App
//
//  Created by Amir Hossein on 7/13/19.
//

import Vapor

class CustomFutureList<T> {
    private var array = [T]()
    private let promise:Promise<[T]>
    private var count:Int
    private var head:Int
    
    init(req:Request,count:Int) {
        self.promise = req.eventLoop.newPromise([T].self)
        self.count = count
        self.head = 0
        
        if count == 0 {
            promise.succeed(result: [])
        }
    }
    
    func futureResult()->Future<[T]>{
        return promise.futureResult
    }
    
    func appendAndIncrementHead(_ value:T) {
        self.array.append(value)
        incrementHead()
    }
    
    func catchAndIncrementHead(error:Error) {
//        AppErrorCatch.printError(error: error)
        incrementHead()
    }
    
    private func incrementHead(){
        self.head += 1
        if self.head == count {
            promise.succeed(result: self.array)
        }
    }
}
