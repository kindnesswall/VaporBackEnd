//
//  ChatRestfulController.swift
//  App
//
//  Created by Amir Hossein on 6/7/19.
//

import Vapor


class ChatRestfulController {
    
    let chatController = ChatController()
    
    private func getRequestInfo(req: Request) throws -> RequestInfo {
        
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.getId()
        return RequestInfo(req: req, userId: userId)
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
            
            return try self.chatController.fetchMessages(reqInfo: reqInfo, fetchMessagesInput: fetchMessagesInput).flatMap({ fetchResult in
                
                let contactMessage = ContactMessage(chatContacts: fetchResult.chatContacts, textMessages: fetchResult.textMessages, contactProfile: nil, notificationCount: nil, blockStatus: nil)
                
                return self.chatController.fetchContactProfile(reqInfo: reqInfo, contactId: fetchResult.chatContacts.contactId, contactMessage: contactMessage)
            })
            
        })
        
    }
    
    func sendMessage(_ req: Request) throws -> Future<AckMessage> {
        
        
        return try req.content.decode(TextMessage.self).flatMap({ textMessage in
            
            return try self.sendMessage(req: req, textMessage: textMessage)
        })
    }
    
    private func sendMessage(req: Request, textMessage: TextMessage) throws -> Future<AckMessage> {
        
        let reqInfo = try getRequestInfo(req: req) 
        
        let chatId = textMessage.chatId
        
        let chat = Chat.getChat(chatId: chatId, conn: req)
        
        return chat.flatMap { chat in
            let chatIsUnblock = chat.isChatUnblock()
            guard chatIsUnblock else {
                throw Constants.errors.chatHasBlocked
            }
            
            let chatContacts = try chat.getChatContacts(userId: reqInfo.userId)
            
            return try self.chatController.saveTextMessage(reqInfo: reqInfo, textMessage: textMessage, chatContacts: chatContacts, receiverId: chatContacts.contactId).map({ textMessage in
                
                try self.sendPushNotification(req, toUserId: chatContacts.contactId, textMessage: textMessage)
                
                // send message to other user active devices
                //                    try self.sendPushNotification(req, toUserId: chatContacts.userId, textMessage: textMessage)
                
                guard let ackMessage = AckMessage(textMessage: textMessage) else {
                    throw Constants.errors.nilMessageId
                }
                return ackMessage
            })
            
        }
    }
    
    
    func sendPushNotification(_ req: Request, toUserId:Int, textMessage: TextMessage) throws {
        
        try textMessage.encode(for: req).map { response in
            guard let data = response.http.body.data else {return}
            guard let text = String(data: data, encoding: .utf8) else {return}
            try PushNotificationController.sendPush(req, userId: toUserId, title: nil, body: textMessage.text, data: text)
        }.catch(AppErrorCatch.printError)
        
    }
    
    func ackMessage(_ req: Request) throws -> Future<HTTPStatus> {
        
        let reqInfo = try getRequestInfo(req: req)
        return try req.content.decode(AckMessage.self).flatMap({ ackMessage in
            return self.chatController.ackMessageIsReceived(reqInfo: reqInfo, ackMessage: ackMessage)
        })
        
    }
    
}
