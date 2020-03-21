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
            return self.fetchContactsInfo(reqInfo: reqInfo, chats: chats)
        }
    }
    
    func fetchBlockedContacts(reqInfo: RequestInfo) throws -> Future<[ContactMessage]>{
        
        return ChatBlock.userBlockedChats(userId: reqInfo.userId, conn: reqInfo.req).flatMap { chatBlocks in
            return self.fetchBlockedContactsInfo(reqInfo: reqInfo, chatBlocks: chatBlocks)
        }
    }
    
    func fetchContactsInfo(reqInfo: RequestInfo, chats: [Chat]) -> Future<[ContactMessage]> {
        var list = [Future<ContactMessage>]()
        for chat in chats {
            guard let chatFuture = try? fetchContactInfo(reqInfo: reqInfo, chat: chat) else { continue }
            list.append(chatFuture)
        }
        
        let future = CustomFutureList(req: reqInfo.req, futures: list)
        return future.futureResult()
    }
    
    func fetchBlockedContactsInfo(reqInfo: RequestInfo, chatBlocks: [ChatBlock]) -> Future<[ContactMessage]> {

        var list = [Future<ContactMessage>]()
        for chatBlock in chatBlocks {
            let chatFuture = fetchBlockedContactInfo(reqInfo: reqInfo, chatBlock: chatBlock)
            list.append(chatFuture)
        }

        let future = CustomFutureList(req: reqInfo.req, futures: list)
        return future.futureResult()
    }
    
    func fetchContactInfo(reqInfo: RequestInfo, chat: Chat) throws -> Future<ContactMessage> {
        
        let blockStatus = try chat.getChatBlockStatus(userId: reqInfo.userId)
        
        guard blockStatus.contactIsBlocked != true else {
            throw Constants.errors.chatHasBlockedByUser
        }
        
        let chatContacts = try chat.getChatContacts(userId: reqInfo.userId)
        
        let contactMessage = ContactMessage(chatContacts: chatContacts, textMessages: nil, contactProfile: nil, notificationCount: nil, blockStatus: blockStatus)
        
        return self.fetchContactNotificationAndProfile(reqInfo: reqInfo, contactMessage: contactMessage)
    }
    
    func fetchBlockedContactInfo(reqInfo: RequestInfo, chatBlock: ChatBlock) -> Future<ContactMessage> {
        
        return Chat.getChat(chatId: chatBlock.chatId, conn: reqInfo.req).flatMap { chat in
            let chatContacts = try chat.getChatContacts(userId: reqInfo.userId)

            let blockStatus = BlockStatus(userIsBlocked: nil, contactIsBlocked: true)

            let contactMessage = ContactMessage(chatContacts: chatContacts, textMessages: nil, contactProfile: nil, notificationCount: nil, blockStatus: blockStatus)

            return self.fetchContactNotificationAndProfile(reqInfo: reqInfo, contactMessage: contactMessage)
        }
    }
    
    func fetchContactNotificationAndProfile(reqInfo: RequestInfo, contactMessage: ContactMessage) -> Future<ContactMessage> {
        
        return ChatNotification.find(userId: reqInfo.userId, chatId: contactMessage.chatId, conn: reqInfo.req).flatMap { chatNotification in
            
            let notificationCount = chatNotification?.notificationCount ?? 0
            contactMessage.notificationCount = notificationCount
            
            return self.fetchContactProfile(reqInfo: reqInfo, contactMessage: contactMessage)
        }
    }
    
    func fetchContactProfile(reqInfo: RequestInfo, contactMessage: ContactMessage)->Future<ContactMessage> {
        
        return User.find(contactMessage.contactId, on: reqInfo.req).map { contactUser in
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

