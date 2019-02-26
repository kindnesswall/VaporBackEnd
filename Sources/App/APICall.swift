//
//  APICall.swift
//  app
//
//  Created by AmirHossein on 3/23/18.
//  Copyright © 2018 Hamed.Gh. All rights reserved.
//

import Foundation

enum HttpCallMethod :String{
    case POST="POST"
    case GET="GET"
    case PUT="PUT"
    case DELETE="DELETE"
}

class APICall {
    
     static func request<InputCodable:Codable>(url urlString:String,httpMethod:HttpCallMethod,input:InputCodable?,complitionHandler:@escaping (Data?,URLResponse?,Error?)->Void) {
        
        var httpBody : Data?
        if let input=input {
            let json=try? JSONEncoder().encode(input)
            if let json=json {
                httpBody=json
            }
        }
        
        request(url: urlString, httpMethod: httpMethod, httpBody: httpBody, complitionHandler: complitionHandler)
        
    }
    
    static func request(url urlString:String,httpMethod:HttpCallMethod,complitionHandler:@escaping (Data?,URLResponse?,Error?)->Void) {
        
        request(url: urlString, httpMethod: httpMethod, httpBody: nil, complitionHandler: complitionHandler)
        
    }
    
    private static func setRequestHeader(request:URLRequest)->URLRequest {
        var newRequest=request
        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return newRequest
    }
    
    private static func request(url urlString:String,httpMethod:HttpCallMethod,httpBody:Data?,complitionHandler:@escaping (Data?,URLResponse?,Error?)->Void) {
        
        guard let url=URL(string:urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod=httpMethod.rawValue
        request=self.setRequestHeader(request: request)
        
        request.httpBody = httpBody
        
        let config=URLSessionConfiguration.default
        let session=URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        let task=session.dataTask(with: request) { (data, response, error) in
            
            if let error = error as NSError? {
                if error.code == NSURLErrorCancelled {
                    //cancelled
                    print("Request Cancelled")
                    return
                }
            }
            
            complitionHandler(data,response,error)
            
        }
        task.resume()
    }
    
    static func printData(data:Data?) {
        guard let data=data else {
            return
        }
        if let dataString=String(data: data, encoding: .utf8) {
            print(dataString)
        }
    }
}
