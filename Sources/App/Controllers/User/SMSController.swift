//
//  SMSController.swift
//  App
//
//  Created by Amir Hossein on 4/29/20.
//

import Vapor

final class SMSController {
    
    static func send(phoneNumber: String, code: String, template: SMSTemplatesType, on req: Request) -> EventLoopFuture<HTTPStatus> {
        
        guard let configuration = configuration.sms,
            let template = configuration.templates[.register],
            let parameterName = template.parameters.first
            else {
                return req.db.makeFailedFuture(
                    .failedToSendSMS)
        }
        
        let apiKey = configuration.apiKey
        let sender = configuration.sender
        let url = URIs().smsURL
        let input = Inputs.SMS(originator: sender,
                               pattern_code: template.pattern_code,
                               recipient: phoneNumber,
                               values: [parameterName:code])
        let headers = [
            ("Content-Type", "application/json"),
            ("Authorization", "AccessKey \(apiKey)")]
        
        return APICall.call(
            req: req,
            url: url,
            httpMethod: .POST,
            headers: headers,
            input: input)
            .map { response in
                //                APICall.log(response)
        }
        .transform(to: .ok)
        
    }
}
