//
//  ChatRestfulController.swift
//  App
//
//  Created by Amir Hossein on 6/7/19.
//

import Vapor


class ChatRestfulController {
    
    let chatController = ChatController()
    
    private func getRequestInfo(req: Request) throws -> ChatRequestInfo{
        
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.nilUserId
        }
        let dataBase = ChatDataBase(req: req)
        let requestInfo = ChatRequestInfo(userId: userId, dataBase: dataBase)
        return requestInfo
    }
    
    func fetchContacts(_ req: Request) throws -> Future<[ContactMessage]> {
        
        let requestInfo = try getRequestInfo(req: req)
        return try chatController.fetchContacts(requestInfo: requestInfo)
    }
    
    func fetchMessages(_ req: Request) throws -> Future<ContactMessage> {
        
        let requestInfo = try getRequestInfo(req: req)
        return try req.content.decode(FetchMessagesInput.self).flatMap({ fetchMessagesInput in
            
            return try self.chatController.fetchMessages(requestInfo: requestInfo, fetchMessagesInput: fetchMessagesInput).flatMap({ fetchResult in
                
                return self.chatController.fetchContactInfo(requestInfo: requestInfo, withTextMessages: fetchResult.textMessages, chat: fetchResult.chat, contactInfoId: fetchResult.chatContacts.contactId)
            })
            
        })
        
    }
    
    func sendMessage(_ req: Request) throws -> Future<AckMessage> {
        
        let requestInfo = try getRequestInfo(req: req)
        return try req.content.decode(TextMessage.self).flatMap({ textMessage in
            return requestInfo.getChatContacts(chatId:textMessage.chatId).flatMap { chatContacts in
                return try self.chatController.saveTextMessage(requestInfo: requestInfo, textMessage: textMessage, chat: chatContacts.chat, receiverId: chatContacts.contactId).map({ textMessage in
                    guard let ackMessage = AckMessage(textMessage: textMessage) else {
                        throw Constants.errors.nilMessageId
                    }
                    return ackMessage
                })
            }
        })
    }
    
    func ackMessage(_ req: Request) throws -> Future<HTTPStatus> {
        
        let requestInfo = try getRequestInfo(req: req)
        return try req.content.decode(AckMessage.self).flatMap({ ackMessage in
            return self.chatController.ackMessageIsReceived(requestInfo: requestInfo, ackMessage: ackMessage)
        })
        
    }
    
}
