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
            let payload = SamplePushPayload()
            try PushNotificationController.sendPush(req, userId: input.userId, title: input.title, body: input.body, payload: payload)
            return .ok
        }
    }
    
    
    static func sendPush<T: PushPayloadable>(_ req: Request, userId:Int, title:String?, body:String, payload: T) throws {
        
        UserPushNotification.findAllTokens(userId: userId, conn: req).map { allTokens in
            
            for token in allTokens {
                try sendPush(req, token: token, title: title, body: body, payload: payload)?.catch({ error in
                    print(error)
                })
            }
        }.catch { error in
            print(error)
        }
    }
    
    static func sendPush<T: PushPayloadable>(_ req: Request, token: UserPushNotification, title:String?, body:String, payload: T) throws -> Future<HTTPStatus>? {
        
        guard let pushType = PushNotificationType(rawValue: token.type) else { return nil }
        
        let click_action = payload.getClickAction(type: pushType)
        
        return try payload.getContent(on: req).flatMap { content in
            switch pushType {
            case .APNS:
                return try sendAPNSPush(req, token: token.devicePushToken, title: title, body: body, content: content)
            case .Firebase:
                return try sendFirebasePush(req, token: token.devicePushToken, title: title, body: body, content: content, click_action: click_action)
            }
        }
        
    }
    
    private static func sendAPNSPush(_ req: Request, token: String, title: String?, body: String, content: PushPayloadContent?) throws -> Future<HTTPStatus> {
        
        guard let payload = APNSPayload(title: title, body: body, data: content?.data).textFormat else {
            throw Constants.errors.pushPayloadIsNotValid
        }
        
        let shell = try req.make(Shell.self)
        
        let appInfo = Constants.appInfo
        let bundleId = appInfo.apnsConfig.bundleId
        let apnsURL = appInfo.apnsConfig.apnsURL
        let certPath = "\(appInfo.fileDirPath)\(appInfo.apnsConfig.certPath)"
        let certPass = appInfo.apnsConfig.certPass
        
        let arguments = ["-d", payload, "-H", "apns-topic:\(bundleId)", "-H", "apns-expiration: 1", "-H", "apns-priority: 10", "--http2", "--cert", "\(certPath):\(certPass)", "\(apnsURL)\(token)"]
        
        return try shell.execute(commandName: "curl", arguments: arguments).map({ output in
            let text = String(data: output, encoding: .utf8)
            print(text ?? "")
        }).transform(to: .ok)
    }
    
    private static func sendFirebasePush(_ req: Request, token: String, title: String?, body: String, content: PushPayloadContent?, click_action: String?) throws -> Future<HTTPStatus> {
        let fcm = try req.make(FCM.self)
        let notification = FCMNotification(title: title ?? "", body: body)
        
        let androidNotification = FCMAndroidNotification(title: title, body: body, sound: "default", click_action: click_action)
        
        let info = Constants.appInfo.firebaseConfig
        let androidConfig = FCMAndroidConfig(ttl: "86400s", restricted_package_name: info.bundleId, notification: androidNotification)
        
        let message = FCMMessage(token: token, notification: notification, android: androidConfig)
        
        if let content = content {
            message.data[content.name] = content.data
        }

        return try fcm.sendMessage(req.client(), message: message).map({ output in
            print(output)
        }).transform(to: .ok)
    }
}
