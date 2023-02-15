
//
//  PushNotificationController.swift
//  App
//
//  Created by Amir Hossein on 6/30/19.
//

import Vapor
import FCM
import APNS

class PushNotificationController: PushRegisterable {
    
    func registerPush(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let userId = try req.auth.require(User.self).getId()
        let tokenId = try req.auth.require(Token.self).requireID()
        let input = try req.content.decode(Inputs.UserPushNotification.self)
        
        return registerPush(userId: userId,
                     userTokenId: tokenId,
                     input: input,
                     on: req.db)
    }
    
    func sendPush(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let input = try req.content.decode(SendPushInput.self)
        let payload = SamplePushPayload()
        try PushNotificationController.sendPush(req, userId: input.userId, title: input.title, body: input.body, payload: payload)
        return req.db.makeSucceededFuture(.ok)
    }
    
    
    static func sendPush<T: PushPayloadable>(_ req: Request, userId:Int, title:String?, body:String, payload: T) throws {
        
        UserPushNotification.findAllTokens(
            userId: userId,
            conn: req.db).flatMapThrowing { allTokens in
            for token in allTokens {
                try sendPush(
                    req,
                    token: token,
                    title: title,
                    body: body,
                    payload: payload)
                    .whenFailure { print($0) }
            }
        }
        .whenFailure { print($0) }
    }
    
    static func sendPush<T: PushPayloadable>(_ req: Request, token: UserPushNotification, title:String?, body:String, payload: T) throws -> EventLoopFuture<HTTPStatus> {
        
        let click_action = try payload.getClickAction(type: token.type)
        
        return payload.getContent(on: req).flatMap { content in
            switch token.type {
            case .APNS:
                return sendAPNSPush(req, token: token.devicePushToken, title: title, body: body, content: content)
            case .Firebase:
                return sendFirebasePush(req, token: token.devicePushToken, title: title, body: body, content: content, click_action: click_action)
            }
        }
        
    }
    
    private static func sendAPNSPush(_ req: Request, token: String, title: String?, body: String, content: PushPayloadContent?) -> EventLoopFuture<HTTPStatus> {
        
        guard let payload = APNSPayload(title: title, body: body, data: content?.data).textFormat else {
            return req.db.makeFailedFuture(.pushPayloadIsNotValid)
        }
        
        //TODO: APNS Implementation
        return req.db.makeFailedFuture(.failedToSendAPNSPush)
        
//        req.apns.send(<#T##notification: APNSwiftNotification##APNSwiftNotification#>, to: <#T##String#>)
    }
    
    private static func sendFirebasePush(_ req: Request, token: String, title: String?, body: String, content: PushPayloadContent?, click_action: String?) -> EventLoopFuture<HTTPStatus> {
        
        //TODO: More study about restricted_package_name field in FCMMessage (Android only)
        
        let message = FCMMessage(token: token, notification: nil)
        
        message.data["body"] = body
        if let title = title {
            message.data["title"] = title
        }
        if let content = content {
            message.data[content.name] = content.data
        }
        if let click_action = click_action {
            message.data["click_action"] = click_action
        }
        
        return req.fcm.send(message, on: req.eventLoop).map { output in
            print(output)
        }.transform(to: .ok)
    }
}
