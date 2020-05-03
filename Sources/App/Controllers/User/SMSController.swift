//
//  SMSController.swift
//  App
//
//  Created by Amir Hossein on 4/29/20.
//

import Vapor

final class SMSController {
    
    static func send(phoneNumber: String, code: String, template: SMSTemplates, on req: Request) throws -> Future<HTTPStatus> {
        
        let url = URIs().getSMSUrl(receptor: phoneNumber, template: template.rawValue, token: code)
        
        return try req.make(Client.self).get(url, headers: [:]).map({ _ in
//            guard let data = response.http.body.data else {
//                return
//            }
//            let text = String(data: data, encoding: .utf8)
//            print(text)
        }).transform(to: .ok)
    }
}
