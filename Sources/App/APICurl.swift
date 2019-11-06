//
//  APICurl.swift
//  App
//
//  Created by Amir Hossein on 11/6/19.
//

import Vapor

class APICurl {
    
    static func curl<InputCodable:Codable>(req: Request, url urlString:String, httpMethod:HttpCallMethod, input: InputCodable?) throws -> Future<Data> {
        
        guard let data = try? JSONEncoder().encode(input),
            let payload = String(data: data, encoding: .utf8)
            else { throw Constants.errors.objectEncodingFailed }
        
        let shell = try req.make(Shell.self)
        
        let arguments = ["-d", payload, "-H", "Content-Type:application/json", "\(urlString)"]
        
        return try shell.execute(commandName: "curl -X \(httpMethod)", arguments: arguments)
        
    }
    
    
    static func log(data: Data){
        let text = String(data: data, encoding: .utf8)
        print(text ?? "Null data")
    }
}
