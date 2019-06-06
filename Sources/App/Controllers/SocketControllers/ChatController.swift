//
//  ChatController.swift
//  App
//
//  Created by Amir Hossein on 6/6/19.
//

import Vapor


class ChatController {
    
    class RequestInfo {
        let userId:Int
        let dataBase:ChatDataBase
        
        init(userId:Int,dataBase:ChatDataBase) {
            self.userId=userId
            self.dataBase=dataBase
        }
    }
    
    //MARK: - Save Messages
    
    func saveTextMessage(requestInfo:RequestInfo,textMessage:TextMessage,chat:Chat,receiverId:Int) throws -> Future<TextMessage>{
        
        textMessage.senderId = requestInfo.userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        
        guard let chatId = chat.id else {
            throw Constants.errors.nilChatId
        }
        
        return requestInfo.dataBase.saveMessage(message: textMessage).map { [weak self] textMessage in
            
            self?.updateChatNotification(requestInfo: requestInfo, notificationUserId: receiverId, chatId: chatId)
            
            return textMessage
        }
    }
    
    func ackMessageIsReceived(requestInfo:RequestInfo,ackMessage:AckMessage) {
        requestInfo.dataBase.getTextMessage(id: ackMessage.messageId).map { message in
            guard let message = message else {
                throw Constants.errors.messageNotFound
            }
            guard message.receiverId == requestInfo.userId else {
                throw Constants.errors.unauthorizedMessage
            }
            if message.ack == false {
                message.ack = true
                
                requestInfo.dataBase.saveMessage(message: message).map({ [weak self] message in
                    self?.updateChatNotification(requestInfo: requestInfo, notificationUserId: requestInfo.userId, chatId: message.chatId)
                }).catch(AppErrorCatch.printError)
                
            }
            
            }.catch(AppErrorCatch.printError)
    }
    
    
    //MARK: - Fetch Messages
    
    func fetchContacts(requestInfo:RequestInfo) throws -> Future<[ContactMessage]>{
        
        let promise = requestInfo.dataBase.getPromise(type: [ContactMessage].self)
        
        let arrayResult = ArrayResult<ContactMessage>()
        
        requestInfo.dataBase.getUserChats(userId: requestInfo.userId).map{ chats in
            let chatsCount = chats.count
            for chat in chats {
                guard let chatContacts = Chat.getChatContacts(userId: requestInfo.userId, chat: chat) else {
                    continue
                }
                
                try self.fetchContact(requestInfo: requestInfo, chat: chat, contactId: chatContacts.contactId).map({ contactMessage in
                    arrayResult.array.append(contactMessage)
                    if arrayResult.array.count == chatsCount {
                        promise.succeed(result: arrayResult.array)
                    }
                }).catch(AppErrorCatch.printError)
                
            }
            }.catch(AppErrorCatch.printError)
        
        return promise.futureResult
        
    }
    
    func fetchContact(requestInfo:RequestInfo,chat:Chat,contactId:Int) throws ->Future<ContactMessage>{
        
        guard let chatId = chat.id else { throw Constants.errors.nilChatId }
        
        return requestInfo.dataBase.findChatNotification(userId: requestInfo.userId, chatId: chatId).flatMap({ chatNotification in
            guard let chatNotification = chatNotification else { throw Constants.errors.chatNotificationNotFound }
            
            return self.fetchContactInfo(requestInfo: requestInfo, withTextMessages: nil, chat: chat, contactId: contactId, notificationCount: chatNotification.notificationCount)
            
            
        }).catch(AppErrorCatch.printError)
    }
    
    func fetchContactInfo(requestInfo:RequestInfo,withTextMessages textMessages: [TextMessage]?,chat:Chat,contactId:Int,notificationCount:Int? = nil)->Future<ContactMessage>{
        
        
        return requestInfo.dataBase.getContactProfile(contactId: contactId).map { contactUser in
            guard let contactUser = contactUser else { throw Constants.errors.contactNotFound }
            let contactInfo = ContactInfo(id: contactId, name: contactUser.name, image: contactUser.image)
            let contactMessage = ContactMessage(chat: chat, textMessages: textMessages, contactInfo: contactInfo, notificationCount: notificationCount)
            return contactMessage
            
            
            }.catch(AppErrorCatch.printError)
    }
    
    
    func fetchMessages(requestInfo:RequestInfo,fetchMessagesInput:FetchMessagesInput) throws -> Future<(chat:Chat,chatContacts:Chat.ChatContacts,textMessages:[TextMessage])>{
        
        return requestInfo.dataBase.getChat(chatId: fetchMessagesInput.chatId).flatMap { chat in
            guard let chat = chat else {
                throw Constants.errors.chatNotFound
            }
            guard Chat.isUserChat(userId: requestInfo.userId, chat: chat),
                let chatContacts = Chat.getChatContacts(userId: requestInfo.userId, chat: chat)
                else {
                    throw Constants.errors.unauthorizedRequest
            }
            
            return requestInfo.dataBase.getTextMessages(chat: chat, beforeId: fetchMessagesInput.beforeId).map({ textMessages in
                return (chat:chat,chatContacts:chatContacts,textMessages:textMessages)
            })
            
        }
        
    }
    
    
    //MARK: - Chat Notifications
    
    
    func updateChatNotification(requestInfo:RequestInfo,notificationUserId:Int,chatId:Int) {
        
        requestInfo.dataBase.calculateNumberOfNotifications(userId: notificationUserId, chatId: chatId).map { notificationCount  in
            
            self.setChatNotification(requestInfo: requestInfo, notificationUserId: notificationUserId, chatId: chatId, notificationCount: notificationCount)
            }.catch(AppErrorCatch.printError)
        
        
    }
    
    private func setChatNotification(requestInfo:RequestInfo,notificationUserId:Int,chatId:Int,notificationCount:Int) {
        
        requestInfo.dataBase.findChatNotification(userId: notificationUserId, chatId: chatId).map { (foundChatNotification) -> Future<ChatNotification> in
            
            var chatNotification:ChatNotification
            if let _chatNotification = foundChatNotification {
                chatNotification = _chatNotification
            } else {
                chatNotification = ChatNotification(userId: notificationUserId, chatId: chatId)
            }
            
            chatNotification.notificationCount = notificationCount
            
            return requestInfo.dataBase.saveChatNotification(chatNotification: chatNotification)
            
            }.catch(AppErrorCatch.printError)
    }
    
}


class ArrayResult<T> {
    var array = [T]()
}
