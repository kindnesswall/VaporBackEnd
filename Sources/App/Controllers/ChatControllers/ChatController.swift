//
//  ChatController.swift
//  App
//
//  Created by Amir Hossein on 6/6/19.
//

import Vapor


class ChatController {
    
    //MARK: - Save Messages
    
    func saveTextMessage(
        reqInfo: RequestInfo,
        textMessage: TextMessage,
        chatId: Int,
        receiverId: Int) -> EventLoopFuture<TextMessage> {
        
        textMessage.senderId = reqInfo.userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        
        return textMessage.save(on: reqInfo.db).flatMap { _ in
            
            return self.updateChatNotification(
                receiverId: receiverId,
                chatId: chatId,
                on: reqInfo.req)
                .transform(to: textMessage)
        }
    }
    
    func ackMessageIsReceived(reqInfo: RequestInfo, ackMessage: AckMessage) -> EventLoopFuture<HTTPStatus> {
        
        return TextMessage.find(
            ackMessage.messageId,
            on: reqInfo.db).flatMap { message in
                guard let message = message else {
                    return reqInfo.db.makeFailedFuture(
                        .messageNotFound)
                }
                guard message.receiverId == reqInfo.userId else {
                    return reqInfo.db.makeFailedFuture(
                        .unauthorizedMessage)
                }
                if message.ack == false {
                    message.ack = true
                    
                    return message.save(on: reqInfo.db).flatMap { _ in
                        return self.updateChatNotification(
                            receiverId: reqInfo.userId,
                            chatId: message.$chat.id,
                            on: reqInfo.req)
                    }.transform(to: .ok)
                    
                } else {
                    return reqInfo.db.makeFailedFuture(
                        .redundentAck)
                }
        }
    }
    
    
    //MARK: - Fetch Contacts
    
    func fetchContacts(reqInfo: RequestInfo) -> EventLoopFuture<[ContactMessage]> {
        
        return DirectChat.userChats(
            blocked: false,
            authId: reqInfo.userId,
            on: reqInfo.req)
    }
    
    func fetchBlockedContacts(reqInfo: RequestInfo) -> EventLoopFuture<[ContactMessage]>{
        
        return DirectChat.userChats(
            blocked: true,
            authId: reqInfo.userId,
            on: reqInfo.req)
    }
    
    //MARK: - Fetch Messages
    
    func fetchMessages(reqInfo: RequestInfo, input: FetchMessagesInput) -> EventLoopFuture<ContactMessage> {
        
        return DirectChat.fetchTextMessages(
            beforeId: input.beforeId,
            authId: reqInfo.userId,
            chatId: input.chatId,
            on: reqInfo.db)
    }
    
    
    //MARK: - Chat Notifications
    
    
    private func updateChatNotification(receiverId: Int, chatId: Int, on req: Request) -> EventLoopFuture<HTTPStatus> {
        
        return TextMessage.calculateNumberOfNotifications(
            userId: receiverId,
            chatId: chatId,
            conn: req.db).flatMap { notificationCount in
            
            return DirectChat.set(
                notification: notificationCount,
                receiverId: receiverId,
                chatId: chatId,
                on: req.db)
        }
    }
    
}

