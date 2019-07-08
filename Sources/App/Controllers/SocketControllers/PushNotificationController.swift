//
//  PushNotificationController.swift
//  App
//
//  Created by Amir Hossein on 6/30/19.
//

import Vapor


class PushNotificationController {
    
    func registerPush(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.nilUserId
        }
        
        return try req.content.decode(UserPushNotification.Input.self).flatMap { input in
            
            
            return UserPushNotification.hasFound(input: input, conn: req).flatMap({ foundPushNotification -> Future<UserPushNotification> in
                
                if let foundPushNotification = foundPushNotification {
                    foundPushNotification.userId = userId
                    return foundPushNotification.save(on: req)
                } else {
                    let pushNotification = UserPushNotification(userId: userId, input: input)
                    return pushNotification.save(on: req)
                }
            }).map({ _ in
                return .ok
            })
            
        }
    }
    
    
    func sendPush(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(SendPushInput.self).map { input in
            try PushNotificationController.sendPush(req, userId: input.userId, title: input.title, body: input.body, data: nil)
            return .ok
        }
    }
    
    static func sendPush(_ req: Request, userId:Int, title:String?, body:String?, data: String?) throws {
        
        guard let payload = PushPayload(title: title, body: body, data: data).textFormat else {
            throw Constants.errors.pushPayloadIsNotValid
        }
        
        UserPushNotification.findAllTokens(userId: userId, type: PushNotificationType.APNS.rawValue, conn: req).map { allTokens in
            for token in allTokens {
                try sendPush(req, token: token.devicePushToken, payload: payload)
            }
        }.catch(AppErrorCatch.printError)
    }
    
    private static func sendPush(_ req: Request,token: String,payload: String) throws {
        
        let shell = try req.make(Shell.self)
        
        let bundleId = AppInfo().apnsConfig.bundleId
        let apnsURL = AppInfo().apnsConfig.apnsURL
        let certPath = AppInfo().apnsConfig.certPath
        let certPass = AppInfo().apnsConfig.certPass
        
        let arguments = ["-d", payload, "-H", "apns-topic:\(bundleId)", "-H", "apns-expiration: 1", "-H", "apns-priority: 10", "--http2", "--cert", "\(certPath):\(certPass)", "\(apnsURL)\(token)"]
        
        try shell.execute(commandName: "curl", arguments: arguments).map({ data in
            let text = String(data: data, encoding: .utf8)
            print(text ?? "")
        }).catch(AppErrorCatch.printError)
    }
}
