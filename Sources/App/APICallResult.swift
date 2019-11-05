//
//  APICallResult.swift
//  App
//
//  Created by Amir Hossein on 11/5/19.
//

import Vapor

class APICallResult<Output> {
    
    var promise: Promise<Output?>
    
    init(req: Request) {
        promise = req.eventLoop.newPromise(of: Output?.self)
    }
    
    func request<InputCodable:Codable>(url urlString:String,httpMethod:HttpCallMethod,input:InputCodable?, requestHandler: @escaping (Data?)->Output?) {
        
        APICall.request(url: urlString, httpMethod: httpMethod, input: input) { (data, response, error) in
            
            let output = requestHandler(data)
            self.promise.succeed(result: output)
        }
        
        
    }
}
