//
//  ChatRestfulController.swift
//  App
//
//  Created by Amir Hossein on 6/7/19.
//

import Vapor


class ChatRestfulController: ChatInitializer {
    
    let chatController = ChatController()
    
    private func getRequestInfo(req: Request) throws -> RequestInfo {
        
        let user = try req.auth.require(User.self)
        let userId = try user.getId()
        return RequestInfo(req: req, userId: userId)
    }
    
    func startChat(_ req: Request) throws -> EventLoopFuture<ContactMessage> {
        let auth = try req.auth.require(User.self)
        return User.getParameter(on: req).flatMap { contact in
            // Use cases:
            // Admin: starts a chat to user/charity
            // User: starts a chat to charity
            guard auth.isAdmin || contact.isCharity else {
                return req.db.makeFailedFuture(
                    .chatIsNotAllowed)
            }
            return self.findOrCreateChat(user: auth, contact: contact, on: req)
        }
    }
    
    func fetchContacts(_ req: Request) throws -> EventLoopFuture<[ContactMessage]> {
        
        let reqInfo = try getRequestInfo(req: req)
        return chatController.fetchContacts(reqInfo: reqInfo)
    }
    
    func fetchBlockedContacts(_ req: Request) throws -> EventLoopFuture<[ContactMessage]> {
        
        let reqInfo = try getRequestInfo(req: req)
        return chatController.fetchBlockedContacts(reqInfo: reqInfo)
    }
    
    func fetchMessages(_ req: Request) throws -> EventLoopFuture<ContactMessage> {
        
        let reqInfo = try getRequestInfo(req: req)
        let fetchMessagesInput = try req.content.decode(FetchMessagesInput.self)
        return self.chatController.fetchMessages(reqInfo: reqInfo, input: fetchMessagesInput)
    }
    
    func sendMessage(_ req: Request) throws -> EventLoopFuture<TextMessage.Output> {
        
        let input = try req.content.decode(Inputs.TextMessage.self)
        return try self.sendMessage(req: req, input: input)
            .outputObject
    }
    
    private func sendMessage(req: Request, input: Inputs.TextMessage) throws -> EventLoopFuture<TextMessage> {
        
        let reqInfo = try getRequestInfo(req: req)
        let textMessage = try TextMessage(input: input)
        let chatId = textMessage.$chat.id
        
        return DirectChat.findOrFail(
            authId: reqInfo.userId,
            chatId: chatId,
            on: req.db).flatMap { chat in
            
            guard !chat.userIsBlocked else {
                return req.db.makeFailedFuture(
                    .chatHasBlocked)
            }
            guard !chat.contactIsBlocked else {
                return req.db.makeFailedFuture(
                    .chatHasBlockedByUser)
            }
            
            return self.chatController.saveTextMessage(
                reqInfo: reqInfo,
                textMessage: textMessage,
                chatId: chatId,
                receiverId: chat.contactId).flatMapThrowing { textMessage in
                
                try self.sendPushNotification(req, toUserId: chat.contactId, textMessage: textMessage)
                
                //TODO: Send message to other active devices of the user
                
                return textMessage
            }
        }
    }
    
    
    func sendPushNotification(_ req: Request, toUserId:Int, textMessage: TextMessage) throws {
        
        try PushNotificationController.sendPush(req, userId: toUserId, title: nil, body: textMessage.text, payload: textMessage)
        
    }
    
    func ackMessage(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let reqInfo = try getRequestInfo(req: req)
        let ackMessage = try req.content.decode(AckMessage.self)
        return self.chatController.ackMessageIsReceived(
            reqInfo: reqInfo,
            ackMessage: ackMessage)
    }
    
}
