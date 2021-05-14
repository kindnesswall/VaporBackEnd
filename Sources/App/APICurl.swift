//
//  APICurl.swift
//  App
//
//  Created by Amir Hossein on 11/6/19.
//

import Vapor

enum HttpCallMethod :String{
    case POST="POST"
    case GET="GET"
    case PUT="PUT"
    case DELETE="DELETE"
}

class APICurl {
    
    static func curl<InputCodable:Codable>(req: Request, url: String, httpMethod: HttpCallMethod, input: InputCodable?) throws -> EventLoopFuture<Data> {
        
        guard let data = try? JSONEncoder().encode(input),
            let payload = String(data: data, encoding: .utf8) else
        {
            throw Abort(.objectEncodingFailed)
        }
        
        return try APICurl.curl(req: req, url: url, httpMethod: httpMethod, payload: payload)
    }
    
    static func curl(req: Request, url: String, httpMethod: HttpCallMethod) throws -> EventLoopFuture<Data> {
        
        return try APICurl.curl(req: req, url: url, httpMethod: httpMethod, payload: nil)
    }
    
    private static func curl(req: Request, url: String, httpMethod:HttpCallMethod, payload: String?) throws -> EventLoopFuture<Data> {
        
        let shell = try req.make(Shell.self)
        let arguments = getArguments(payload: payload, url: url)
        
        return try shell.execute(commandName: "curl -X \(httpMethod)", arguments: arguments)
        
    }
    
    private static func getArguments(payload: String?, url: String) -> [String] {
        
        // For more information about curl arguments, run the following command in terminal
        // # curl --help
        
        var arguments: [String]
        if let payload = payload {
            arguments = ["-d", payload]
        } else {
            arguments = []
        }
        
        let header = ["-H", "Content-Type:application/json"]
        arguments.append(contentsOf: header)
        arguments.append(url)
        
        return arguments
    }
    
    
    static func log(data: Data){
        let text = String(data: data, encoding: .utf8)
        print(text ?? "Null data")
    }
}
