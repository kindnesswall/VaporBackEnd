//
//  APICall.swift
//  App
//
//  Created by Amir Hossein on 11/6/19.
//

import Vapor

class APICall {
    
    static func call<InputCodable: Codable>(
        req: Request,
        url: String,
        httpMethod: HTTPMethod,
        headers: [(String, String)]? = nil,
        input: InputCodable?) -> EventLoopFuture<ClientResponse> {
        
        guard
            let data = try? JSONEncoder().encode(input)
            else {
                return req.db.makeFailedFuture(.objectEncodingFailed)
        }
        
        return call(
            req: req,
            url: url,
            httpMethod: httpMethod,
            headers: headers,
            payload: ByteBuffer(data: data))
    }
    
    static func call(
        req: Request,
        url: String,
        httpMethod: HTTPMethod,
        headers: [(String, String)]? = nil) -> EventLoopFuture<ClientResponse> {
        return call(
            req: req,
            url: url,
            httpMethod: httpMethod,
            headers: headers,
            payload: nil)
    }
    
    private static func call(
        req: Request,
        url: String,
        httpMethod: HTTPMethod,
        headers: [(String, String)]?,
        payload: ByteBuffer?) -> EventLoopFuture<ClientResponse> {
        
        let defaultHeaders = [("Content-Type", "application/json")]
        let clientRequest = ClientRequest(
            method: httpMethod,
            url: URI(string: url),
            headers: HTTPHeaders(headers ?? defaultHeaders),
            body: payload)
        return req.client.send(clientRequest)
        
    }
    
    static func log(_ response: ClientResponse){
        guard
            let buffer = response.body,
            let text = String(data: Data(buffer: buffer), encoding: .utf8)
            else { print("Null data") }
        print(text)
    }
}
