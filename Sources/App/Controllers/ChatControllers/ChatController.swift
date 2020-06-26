//
//  ChatController.swift
//  App
//
//  Created by Amir Hossein on 6/6/19.
//

import Vapor


class ChatController {
    
    //MARK: - Save Messages
    
    func saveTextMessage(reqInfo: RequestInfo, textMessage: TextMessage, chatId: Int, receiverId: Int) throws -> Future<TextMessage> {
        
        textMessage.senderId = reqInfo.userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        
        return textMessage.save(on: reqInfo.req).flatMap { textMessage in
            
            return self.updateChatNotification(receiverId: receiverId, chatId: chatId, on: reqInfo.req).map({ _ in
                return textMessage
            })
        }
    }
    
    func ackMessageIsReceived(reqInfo: RequestInfo, ackMessage: AckMessage) -> Future<HTTPStatus> {
        
        return TextMessage.find(ackMessage.messageId, on: reqInfo.req).flatMap { message in
            guard let message = message else {
                throw Abort(.messageNotFound)
            }
            guard message.receiverId == reqInfo.userId else {
                throw Abort(.unauthorizedMessage)
            }
            if message.ack == false {
                message.ack = true
                
                return message.save(on: reqInfo.req).flatMap({ message in
                    return self.updateChatNotification(receiverId: reqInfo.userId, chatId: message.chatId, on: reqInfo.req)
                }).transform(to: .ok)
                
            } else {
                throw Abort(.redundentAck)
            }
        }
    }
    
    
    //MARK: - Fetch Contacts
    
    func fetchContacts(reqInfo: RequestInfo) throws -> Future<[ContactMessage]> {
        
        return DirectChat.userChats(blocked: false, userId: reqInfo.userId, on: reqInfo.req)
    }
    
    func fetchBlockedContacts(reqInfo: RequestInfo) throws -> Future<[ContactMessage]>{
        
        return DirectChat.userChats(blocked: true, userId: reqInfo.userId, on: reqInfo.req)
    }
    
    //MARK: - Fetch Messages
    
    func fetchMessages(reqInfo: RequestInfo, input: FetchMessagesInput) throws -> Future<ContactMessage> {
        
        return DirectChat.fetchTextMessages(beforeId: input.beforeId, authId: reqInfo.userId, chatId: input.chatId, on: reqInfo.req)
        
    }
    
    
    //MARK: - Chat Notifications
    
    
    private func updateChatNotification(receiverId: Int, chatId: Int, on req: Request) -> Future<HTTPStatus> {
        
        return TextMessage.calculateNumberOfNotifications(userId: receiverId, chatId: chatId, conn: req).flatMap { notificationCount in
            
            return DirectChat.set(notification: notificationCount, receiverId: receiverId, chatId: chatId, on: req)
        }
    }
    
}

