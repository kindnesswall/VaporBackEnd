//
//  ChatController.swift
//  App
//
//  Created by Amir Hossein on 6/6/19.
//

import Vapor


class ChatController {
    
    //MARK: - Save Messages
    
    func saveTextMessage(reqInfo: RequestInfo, textMessage: TextMessage, chatContacts: Chat.ChatContacts, receiverId: Int) throws -> Future<TextMessage> {
        
        textMessage.senderId = reqInfo.userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        
        return textMessage.save(on: reqInfo.req).flatMap { textMessage in
            
            return self.updateChatNotification(reqInfo: reqInfo, notificationUserId: receiverId, chatId: chatContacts.chatId).map({ _ in
                return textMessage
            })
        }
    }
    
    func ackMessageIsReceived(reqInfo: RequestInfo, ackMessage: AckMessage) -> Future<HTTPStatus> {
        
        return TextMessage.find(ackMessage.messageId, on: reqInfo.req).flatMap { message in
            guard let message = message else {
                throw Constants.errors.messageNotFound
            }
            guard message.receiverId == reqInfo.userId else {
                throw Constants.errors.unauthorizedMessage
            }
            if message.ack == false {
                message.ack = true
                
                return message.save(on: reqInfo.req).flatMap({ message in
                    return self.updateChatNotification(reqInfo: reqInfo, notificationUserId: reqInfo.userId, chatId: message.chatId)
                }).transform(to: .ok)
                
            } else {
                throw Constants.errors.redundentAck
            }
        }
    }
    
    
    //MARK: - Fetch Messages
    
    class FetchMessagesResult {
        let chatContacts:Chat.ChatContacts
        let textMessages:[TextMessage]
        init(chatContacts:Chat.ChatContacts,textMessages:[TextMessage]) {
            self.chatContacts=chatContacts
            self.textMessages=textMessages
        }
    }
    
    func fetchContacts(reqInfo: RequestInfo) throws -> Future<[ContactMessage]> {
        
        return Chat.userChats(userId: reqInfo.userId, conn: reqInfo.req).flatMap { chats in
            return try self.fetchContactsInfo(reqInfo: reqInfo, chats: chats)
        }
    }
    
    func fetchBlockedContacts(reqInfo: RequestInfo) throws -> Future<[ContactMessage]>{
        
        return ChatBlock.userBlockedChats(userId: reqInfo.userId, conn: reqInfo.req).flatMap { chatBlocks in
            return try self.fetchBlockedContactsInfo(reqInfo: reqInfo, chatBlocks: chatBlocks)
        }
    }
    
    func fetchContactsInfo(reqInfo: RequestInfo, chats: [Chat]) throws -> Future<[ContactMessage]> {
        
        let arrayResult = CustomFutureList<ContactMessage>(req: reqInfo.req, count: chats.count)
        
        for chat in chats {
            
            chat.getIdFuture(req: reqInfo.req).flatMap { chatId -> Future<Void> in
                
                let blockStatus = try chat.getChatBlockStatus(userId: reqInfo.userId)
                
                guard blockStatus.contactIsBlocked != true else {
                    throw Constants.errors.chatHasBlockedByUser
                }
                
                let chatContacts = try chat.getChatContacts(userId: reqInfo.userId)
                
                let contactMessage = ContactMessage(chatContacts: chatContacts, textMessages: nil, contactProfile: nil, notificationCount: nil, blockStatus: blockStatus)
                
                return self.fetchContactProfileAndNotification(reqInfo: reqInfo, contactId: chatContacts.contactId, chatId: chatId, contactMessage: contactMessage).map({ contactMessage in
                    
                    arrayResult.appendAndIncrementHead(contactMessage)
                })
                
                }.catch(arrayResult.catchAndIncrementHead)
            
        }
        
        return arrayResult.futureResult()
    }
    
    func fetchBlockedContactsInfo(reqInfo: RequestInfo, chatBlocks: [ChatBlock]) throws -> Future<[ContactMessage]> {
        
        let arrayResult = CustomFutureList<ContactMessage>(req: reqInfo.req, count: chatBlocks.count)
        
        for chatBlock in chatBlocks {
            
            Chat.getChat(chatId: chatBlock.chatId, conn: reqInfo.req).flatMap { chat -> Future<Void> in
                let chatContacts = try chat.getChatContacts(userId: reqInfo.userId)
                
                let blockStatus = BlockStatus(userIsBlocked: nil, contactIsBlocked: true)
                
                let contactMessage = ContactMessage(chatContacts: chatContacts, textMessages: nil, contactProfile: nil, notificationCount: nil, blockStatus: blockStatus)
                
                return self.fetchContactProfileAndNotification(reqInfo: reqInfo, contactId: chatContacts.contactId, chatId: chatBlock.chatId, contactMessage: contactMessage).map({ contactMessage in
                    arrayResult.appendAndIncrementHead(contactMessage)
                })
                
            }.catch(arrayResult.catchAndIncrementHead)
        }
        
        return arrayResult.futureResult()
    }
    
    func fetchContactProfileAndNotification(reqInfo: RequestInfo, contactId: Int, chatId: Int, contactMessage: ContactMessage) -> Future<ContactMessage> {
        
        return ChatNotification.find(userId: reqInfo.userId, chatId: chatId, conn: reqInfo.req).flatMap { chatNotification in
            
            let notificationCount = chatNotification?.notificationCount ?? 0
            contactMessage.notificationCount = notificationCount
            
            return self.fetchContactProfile(reqInfo: reqInfo, contactId: contactId, contactMessage: contactMessage)
        }
    }
    
    func fetchContactProfile(reqInfo: RequestInfo, contactId: Int, contactMessage: ContactMessage)->Future<ContactMessage> {
        
        return User.find(contactId, on: reqInfo.req).map { contactUser in
            guard let contactUser = contactUser else { throw Constants.errors.contactNotFound }
            let contactProfile = try contactUser.userProfile(req: reqInfo.req)
            contactMessage.contactProfile = contactProfile
            return contactMessage
        }
    }
    
    
    func fetchMessages(reqInfo: RequestInfo, fetchMessagesInput: FetchMessagesInput) throws -> Future<FetchMessagesResult> {
        
        return Chat.getChat(chatId: fetchMessagesInput.chatId, conn: reqInfo.req).flatMap { chat in
            
            guard chat.isUserChat(userId: reqInfo.userId) else { throw Constants.errors.unauthorizedRequest }
            
            let chatContacts = try chat.getChatContacts(userId: reqInfo.userId)
            
            return try TextMessage.getTextMessages(chat: chat, beforeId: fetchMessagesInput.beforeId, conn: reqInfo.req).map { textMessages in
                return FetchMessagesResult(chatContacts:chatContacts,textMessages:textMessages)
            }
        }
    }
    
    
    //MARK: - Chat Notifications
    
    
    private func updateChatNotification(reqInfo: RequestInfo, notificationUserId: Int, chatId: Int) -> Future<ChatNotification> {
        
        return TextMessage.calculateNumberOfNotifications(userId: notificationUserId, chatId: chatId, conn: reqInfo.req).flatMap { notificationCount  in
            
            return self.setChatNotification(reqInfo: reqInfo, notificationUserId: notificationUserId, chatId: chatId, notificationCount: notificationCount)
        }
    }
    
    private func setChatNotification(reqInfo: RequestInfo, notificationUserId: Int, chatId: Int, notificationCount: Int)-> Future<ChatNotification> {
        
        return ChatNotification.find(userId: notificationUserId, chatId: chatId, conn: reqInfo.req).flatMap { foundChatNotification in
            
            var chatNotification:ChatNotification
            if let _chatNotification = foundChatNotification {
                chatNotification = _chatNotification
            } else {
                chatNotification = ChatNotification(userId: notificationUserId, chatId: chatId)
            }
            
            chatNotification.notificationCount = notificationCount
            return chatNotification.save(on: reqInfo.req)
        }
    }
    
}

