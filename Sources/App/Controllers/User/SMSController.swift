//
//  SMSController.swift
//  App
//
//  Created by Amir Hossein on 4/29/20.
//

import Vapor

final class SMSController {
    
    static func send(phoneNumber: String, code: String, template: SMSTemplatesType, on req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        guard let configuration = configuration.sms,
            let template = configuration.templates[.register],
            let parameterName = template.parameters.first
            else {
                throw Abort(.failedToSendSMS)
        }
        
        let apiKey = configuration.apiKey
        let sender = configuration.sender
        let url = URIs().smsURL
        
        let headers: HTTPHeaders = ["Authorization":"AccessKey \(apiKey)", "Content-Type":"application/json"]
        
        let input = Inputs.SMS(originator: sender,
                               pattern_code: template.pattern_code,
                               recipient: phoneNumber,
                               values: [parameterName:code])
        let data = try? JSONEncoder().encode(input)
        
        return try req.make(Client.self).post(url, headers: headers, beforeSend: { req in
            if let data = data {
                req.http.body = HTTPBody(data: data)
            }
        }).map { data in
//            print(data.http.status)
        }.mapIfError { error in
            print(error)
        }.transform(to: .ok)
        
    }
}
