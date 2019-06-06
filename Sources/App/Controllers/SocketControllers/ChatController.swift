//
//  ChatController.swift
//  App
//
//  Created by Amir Hossein on 6/6/19.
//

import Vapor


class ChatController {
    
    //MARK: - Save Messages
    
    func saveTextMessage(userId:Int,socketDB:SocketDataBaseController,textMessage:TextMessage,chat:Chat,receiverId:Int) throws -> Future<TextMessage>{
        
        textMessage.senderId = userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        
        guard let chatId = chat.id else {
            throw Constants.errors.nilChatId
        }
        
        return socketDB.saveMessage(message: textMessage).map { [weak self] textMessage in
            
            self?.updateChatNotification(userId: receiverId, chatId: chatId, socketDB: socketDB)
            
            return textMessage
        }
    }
    
    func ackMessageIsReceived(userId:Int,socketDB:SocketDataBaseController,ackMessage:AckMessage) {
        socketDB.getTextMessage(id: ackMessage.messageId).map { message in
            guard let message = message else {
                throw Constants.errors.messageNotFound
            }
            guard message.receiverId == userId else {
                throw Constants.errors.unauthorizedMessage
            }
            if message.ack == false {
                message.ack = true
                
                socketDB.saveMessage(message: message).map({ [weak self] message in
                    self?.updateChatNotification(userId: userId, chatId: message.chatId, socketDB: socketDB)
                }).catch(AppErrorCatch.printError)
                
            }
            
            }.catch(AppErrorCatch.printError)
    }
    
    
    //MARK: - Fetch Messages
    
    func fetchContacts(userId:Int,socketDB:SocketDataBaseController) throws -> Future<[ContactMessage]>{
        
        let promise = socketDB.getPromise(type: [ContactMessage].self)
        
        let arrayResult = ArrayResult<ContactMessage>()
        
        socketDB.getUserChats(userId: userId).map{ chats in
            let chatsCount = chats.count
            for chat in chats {
                guard let chatContacts = Chat.getChatContacts(userId: userId, chat: chat) else {
                    continue
                }
                
                try self.fetchContact(userId: userId, socketDB: socketDB, chat: chat, contactId: chatContacts.contactId).map({ contactMessage in
                    arrayResult.array.append(contactMessage)
                    if arrayResult.array.count == chatsCount {
                        promise.succeed(result: arrayResult.array)
                    }
                }).catch(AppErrorCatch.printError)
                
            }
            }.catch(AppErrorCatch.printError)
        
        return promise.futureResult
        
    }
    
    func fetchContact(userId:Int,socketDB:SocketDataBaseController,chat:Chat,contactId:Int) throws ->Future<ContactMessage>{
        
        guard let chatId = chat.id else { throw Constants.errors.nilChatId }
        
        return socketDB.findChatNotification(userId: userId, chatId: chatId).flatMap({ chatNotification in
            guard let chatNotification = chatNotification else { throw Constants.errors.chatNotificationNotFound }
            
            return self.fetchContactInfo(withTextMessages: nil, socketDB: socketDB, chat: chat, contactId: contactId, notificationCount: chatNotification.notificationCount)
            
            
        }).catch(AppErrorCatch.printError)
    }
    
    func fetchContactInfo(withTextMessages textMessages: [TextMessage]?,socketDB:SocketDataBaseController,chat:Chat,contactId:Int,notificationCount:Int? = nil)->Future<ContactMessage>{
        
        
        return socketDB.getContactProfile(contactId: contactId).map { contactUser in
            guard let contactUser = contactUser else { throw Constants.errors.contactNotFound }
            let contactInfo = ContactInfo(id: contactId, name: contactUser.name, image: contactUser.image)
            let contactMessage = ContactMessage(chat: chat, textMessages: textMessages, contactInfo: contactInfo, notificationCount: notificationCount)
            return contactMessage
            
            
            }.catch(AppErrorCatch.printError)
    }
    
    
    func fetchMessages(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,fetchMessagesInput:FetchMessagesInput) throws -> Future<(chat:Chat,chatContacts:Chat.ChatContacts,textMessages:[TextMessage])>{
        
        return socketDB.getChat(chatId: fetchMessagesInput.chatId).flatMap { chat in
            guard let chat = chat else {
                throw Constants.errors.chatNotFound
            }
            guard Chat.isUserChat(userId: userId, chat: chat),
                let chatContacts = Chat.getChatContacts(userId: userId, chat: chat)
                else {
                    throw Constants.errors.unauthorizedRequest
            }
            
            return socketDB.getTextMessages(chat: chat, beforeId: fetchMessagesInput.beforeId).map({ textMessages in
                return (chat:chat,chatContacts:chatContacts,textMessages:textMessages)
            })
            
        }
        
    }
    
    
    //MARK: - Chat Notifications
    
    
    func updateChatNotification(userId:Int,chatId:Int,socketDB:SocketDataBaseController) {
        
        socketDB.calculateNumberOfNotifications(userId: userId, chatId: chatId).map { notificationCount  in
            
            self.setChatNotification(userId: userId, chatId: chatId, notificationCount: notificationCount, socketDB: socketDB)
            }.catch(AppErrorCatch.printError)
        
        
    }
    
    func setChatNotification(userId:Int,chatId:Int,notificationCount:Int,socketDB:SocketDataBaseController) {
        
        socketDB.findChatNotification(userId: userId, chatId: chatId).map { (foundChatNotification) -> Future<ChatNotification> in
            
            var chatNotification:ChatNotification
            if let _chatNotification = foundChatNotification {
                chatNotification = _chatNotification
            } else {
                chatNotification = ChatNotification(userId: userId, chatId: chatId)
            }
            
            chatNotification.notificationCount = notificationCount
            
            return socketDB.saveChatNotification(chatNotification: chatNotification)
            
            }.catch(AppErrorCatch.printError)
    }
    
}


class ArrayResult<T> {
    var array = [T]()
}
