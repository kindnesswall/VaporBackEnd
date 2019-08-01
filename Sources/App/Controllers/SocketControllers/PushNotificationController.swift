//
//  PushNotificationController.swift
//  App
//
//  Created by Amir Hossein on 6/30/19.
//

import Vapor
import FCM

class PushNotificationController {
    
    func registerPush(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.nilUserId
        }
        
        return try req.content.decode(UserPushNotification.Input.self).flatMap { input in
            
            guard let _ = PushNotificationType(rawValue: input.type) else {
                throw Constants.errors.wrongPushNotificationType
            }
            
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
    
    static func sendPush(_ req: Request, userId:Int, title:String?, body:String, data: String?) throws {
        
        UserPushNotification.findAllTokens(userId: userId, conn: req).map { allTokens in
            for token in allTokens {
                
                guard let pushType = PushNotificationType(rawValue: token.type) else { continue }
                switch pushType {
                case .APNS:
                    try sendAPNSPush(req, token: token.devicePushToken, title: title, body: body, data: data)
                case .Firebase:
                    try sendFirebasePush(req, token: token.devicePushToken, title: title, body: body, data: data)
                }
            }
        }.catch(AppErrorCatch.printError)
    }
    
    private static func sendAPNSPush(_ req: Request,token: String,title:String?, body:String, data: String?) throws {
        
        guard let payload = APNSPayload(title: title, body: body, data: data).textFormat else {
            throw Constants.errors.pushPayloadIsNotValid
        }
        
        let shell = try req.make(Shell.self)
        
        let bundleId = AppInfo().apnsConfig.bundleId
        let apnsURL = AppInfo().apnsConfig.apnsURL
        let certPath = AppInfo().apnsConfig.certPath
        let certPass = AppInfo().apnsConfig.certPass
        
        let arguments = ["-d", payload, "-H", "apns-topic:\(bundleId)", "-H", "apns-expiration: 1", "-H", "apns-priority: 10", "--http2", "--cert", "\(certPath):\(certPass)", "\(apnsURL)\(token)"]
        
        try shell.execute(commandName: "curl", arguments: arguments).map({ output in
            let text = String(data: output, encoding: .utf8)
            print(text ?? "")
        }).catch(AppErrorCatch.printError)
    }
    
    private static func sendFirebasePush(_ req:Request,token: String, title:String?, body:String, data:String?) throws {
        let fcm = try req.make(FCM.self)
        let notification = FCMNotification(title: title ?? "", body: body)
        let message = FCMMessage(token: token, notification: notification)
        if let data = data {
            message.data["message"] = data
        }
        try fcm.sendMessage(req.client(), message: message).catch({ error in
            print(error)
        })
    }
}
