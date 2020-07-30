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
        
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.getId()
        return RequestInfo(req: req, userId: userId)
    }
    
    func startChat(_ req: Request) throws -> Future<ContactMessage> {
        let auth = try req.requireAuthenticated(User.self)
        return try req.parameters.next(User.self).flatMap({ contact in
            // Use cases:
            // Admin: starts a chat to user/charity
            // User: starts a chat to charity
            guard auth.isAdmin || contact.isCharity else {
                throw Abort(.chatIsNotAllowed)
            }
            return try self.findOrCreateChat(user: auth, contact: contact, on: req)
        })
    }
    
    func fetchContacts(_ req: Request) throws -> Future<[ContactMessage]> {
        
        let reqInfo = try getRequestInfo(req: req)
        return try chatController.fetchContacts(reqInfo: reqInfo)
    }
    
    func fetchBlockedContacts(_ req: Request) throws -> Future<[ContactMessage]> {
        
        let reqInfo = try getRequestInfo(req: req)
        return try chatController.fetchBlockedContacts(reqInfo: reqInfo)
    }
    
    func fetchMessages(_ req: Request) throws -> Future<ContactMessage> {
        
        let reqInfo = try getRequestInfo(req: req)
        return try req.content.decode(FetchMessagesInput.self).flatMap({ fetchMessagesInput in
            
            return try self.chatController.fetchMessages(reqInfo: reqInfo, input: fetchMessagesInput)
        })
        
    }
    
    func sendMessage(_ req: Request) throws -> Future<TextMessage> {
        
        return try req.content.decode(Inputs.TextMessage.self).flatMap({ input in
            return try self.sendMessage(req: req, input: input)
        })
    }
    
    private func sendMessage(req: Request, input: Inputs.TextMessage) throws -> Future<TextMessage> {
        
        let reqInfo = try getRequestInfo(req: req)
        let textMessage = try TextMessage(input: input)
        let chatId = textMessage.chatId
        
        return DirectChat.findOrFail(authId: reqInfo.userId, chatId: chatId, on: req).flatMap { chat in
            
            guard !chat.userIsBlocked else {
                throw Abort(.chatHasBlocked)
            }
            guard !chat.contactIsBlocked else {
                throw Abort(.chatHasBlockedByUser)
            }
            
            return try self.chatController.saveTextMessage(reqInfo: reqInfo, textMessage: textMessage, chatId: chatId, receiverId: chat.contactId).map({ textMessage in
                
                try self.sendPushNotification(req, toUserId: chat.contactId, textMessage: textMessage)
                
                //TODO: Send message to other active devices of the user
                
                return textMessage
            })
        }
    }
    
    
    func sendPushNotification(_ req: Request, toUserId:Int, textMessage: TextMessage) throws {
        
        try PushNotificationController.sendPush(req, userId: toUserId, title: nil, body: textMessage.text, payload: textMessage)
        
    }
    
    func ackMessage(_ req: Request) throws -> Future<HTTPStatus> {
        
        let reqInfo = try getRequestInfo(req: req)
        return try req.content.decode(AckMessage.self).flatMap({ ackMessage in
            return self.chatController.ackMessageIsReceived(reqInfo: reqInfo, ackMessage: ackMessage)
        })
        
    }
    
}
