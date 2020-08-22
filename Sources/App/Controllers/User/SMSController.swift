//
//  SMSController.swift
//  App
//
//  Created by Amir Hossein on 4/29/20.
//

import Vapor

final class SMSController {
    
    static func send(phoneNumber: String, code: String, template: SMSTemplates, on req: Request) throws -> Future<HTTPStatus> {
        
        let smsConfig = Constants.appInfo.smsConfig
        let apiKey = smsConfig.apiKey
        let sender = smsConfig.sender
        let url = URIs().smsURL
        
        let headers: HTTPHeaders = ["Authorization":"AccessKey \(apiKey)", "Content-Type":"application/json"]
        
        let input = Inputs.SMS(originator: sender,
                               pattern_code: template.rawValue,
                               recipient: phoneNumber,
                               values: [template.parameter:code])
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
