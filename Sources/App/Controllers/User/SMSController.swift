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
            guard let url = URIs().getSMSUrl(apiKey: smsConfig.apiKey, receptor: phoneNumber, template: template.rawValue, token: code) else {
                throw Constants.errors.smsSendingFailed
            }
            
            return try APICurl.curl(req: req, url: url, httpMethod: .POST).map({ _ in
    //            APICurl.log(data: data)
            }).transform(to: .ok)
            
        }
}
