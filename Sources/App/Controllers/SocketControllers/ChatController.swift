//
//  ChatController.swift
//  App
//
//  Created by Amir Hossein on 6/6/19.
//

import Vapor


class ChatController {
    
    //MARK: - Save Messages
    
    func saveTextMessage(requestInfo:ChatRequestInfo,textMessage:TextMessage,chatContacts:Chat.ChatContacts,receiverId:Int) throws -> Future<TextMessage> {
        
        textMessage.senderId = requestInfo.userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        
        return requestInfo.dataBase.saveMessage(message: textMessage).flatMap { textMessage in
            
            return self.updateChatNotification(requestInfo: requestInfo, notificationUserId: receiverId, chatId: chatContacts.chatId).map({ _ in
                return textMessage
            })
            
        }
    }
    
    func ackMessageIsReceived(requestInfo:ChatRequestInfo,ackMessage:AckMessage) -> Future<HTTPStatus> {
        return requestInfo.dataBase.getTextMessage(id: ackMessage.messageId).flatMap { message in
            guard let message = message else {
                throw Constants.errors.messageNotFound
            }
            guard message.receiverId == requestInfo.userId else {
                throw Constants.errors.unauthorizedMessage
            }
            if message.ack == false {
                message.ack = true
                
                return requestInfo.dataBase.saveMessage(message: message).flatMap({ message in
                    return self.updateChatNotification(requestInfo: requestInfo, notificationUserId: requestInfo.userId, chatId: message.chatId)
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
    
    func fetchContacts(requestInfo:ChatRequestInfo) throws -> Future<[ContactMessage]>{
        
        return requestInfo.getUserChats().flatMap{ chats in
            return try self.fetchContactsInfo(requestInfo: requestInfo, chats: chats)
        }
    }
    
    func fetchBlockedContacts(requestInfo:ChatRequestInfo) throws -> Future<[ContactMessage]>{

        return requestInfo.getUserBlockedChats().flatMap({ chatBlocks in
            return try self.fetchBlockedContactsInfo(requestInfo: requestInfo, chatBlocks: chatBlocks)
        })
    }
    
    func fetchContactsInfo(requestInfo:ChatRequestInfo,chats:[Chat]) throws -> Future<[ContactMessage]> {
        
        let req = try requestInfo.dataBase.getRequest()
        
        let arrayResult = CustomFutureList<ContactMessage>(req: req, count: chats.count)
        
        for chat in chats {
            
            
            chat.getIdFuture(req: req).flatMap { chatId in
                
                return ChatBlock.getChatBlockStatus(userId: requestInfo.userId, chatId: chatId, conn: req).flatMap { blockStatus -> Future<Void> in
                    
                    guard blockStatus.blockedByUser != true else {
                        throw Constants.errors.chatHasBlockedByUser
                    }
                    
                    let chatContacts = try Chat.getChatContacts(userId: requestInfo.userId, chat: chat)
                    
                    let contactMessage = ContactMessage(chatContacts: chatContacts, textMessages: nil, contactProfile: nil, notificationCount: nil, blockStatus: blockStatus)
                    
                    return self.fetchContactProfileAndNotification(requestInfo: requestInfo, contactId: chatContacts.contactId, chatId: chatId, contactMessage: contactMessage).map({ contactMessage in
                        
                        arrayResult.appendAndIncrementHead(contactMessage)
                    })
                }
            }.catch(arrayResult.catchAndIncrementHead)
            
        }
        
        return arrayResult.futureResult()
    }
    
    func fetchBlockedContactsInfo(requestInfo:ChatRequestInfo,chatBlocks:[ChatBlock]) throws -> Future<[ContactMessage]> {
        
        let req = try requestInfo.dataBase.getRequest()
        
        let arrayResult = CustomFutureList<ContactMessage>(req: req, count: chatBlocks.count)
        
        for chatBlock in chatBlocks {
            
            let chatContacts = requestInfo.getChatContacts(chatId: chatBlock.chatId)
            chatContacts.flatMap({ chatContacts -> Future<Void> in
                
                let blockStatus = ChatBlock.BlockStatus(blockedByUser: true, blockedByContact: nil)
                
                let contactMessage = ContactMessage(chatContacts: chatContacts, textMessages: nil, contactProfile: nil, notificationCount: nil, blockStatus: blockStatus)
                
                return self.fetchContactProfileAndNotification(requestInfo: requestInfo, contactId: chatContacts.contactId, chatId: chatBlock.chatId, contactMessage: contactMessage).map({ contactMessage in
                    arrayResult.appendAndIncrementHead(contactMessage)
                })
            }).catch(arrayResult.catchAndIncrementHead)
        }
        
        return arrayResult.futureResult()
    }
        
    func fetchContactProfileAndNotification(requestInfo:ChatRequestInfo,contactId:Int,chatId:Int,contactMessage:ContactMessage) -> Future<ContactMessage>{
        
        return requestInfo.dataBase.findChatNotification(notificationUserId: requestInfo.userId, chatId: chatId).flatMap({ chatNotification in
            
            let notificationCount = chatNotification?.notificationCount ?? 0
            contactMessage.notificationCount = notificationCount
            
            return self.fetchContactProfile(requestInfo: requestInfo, contactId: contactId, contactMessage: contactMessage)
            
            
        }).catch(AppErrorCatch.printError)
    }
    
    func fetchContactProfile(requestInfo:ChatRequestInfo,contactId:Int,contactMessage:ContactMessage)->Future<ContactMessage>{
        
        
        return requestInfo.dataBase.getContactProfile(contactId: contactId).map { contactUser in
            guard let contactUser = contactUser else { throw Constants.errors.contactNotFound }
            let req = try requestInfo.dataBase.getRequest()
            let contactProfile = try contactUser.userProfile(req: req)
            
            contactMessage.contactProfile = contactProfile
            return contactMessage
            
            }.catch(AppErrorCatch.printError)
    }
    
    
    func fetchMessages(requestInfo:ChatRequestInfo,fetchMessagesInput:FetchMessagesInput) throws -> Future<FetchMessagesResult>{
        
        return requestInfo.dataBase.getChat(chatId: fetchMessagesInput.chatId).flatMap { chat in
            guard let chat = chat else {
                throw Constants.errors.chatNotFound
            }
            guard Chat.isUserChat(userId: requestInfo.userId, chat: chat) else { throw Constants.errors.unauthorizedRequest }
            
            let chatContacts = try Chat.getChatContacts(userId: requestInfo.userId, chat: chat)
            
            return requestInfo.dataBase.getTextMessages(chat: chat, beforeId: fetchMessagesInput.beforeId).map({ textMessages in
                return FetchMessagesResult(chatContacts:chatContacts,textMessages:textMessages)
            })
        }
        
    }
    
    
    //MARK: - Chat Notifications
    
    
    private func updateChatNotification(requestInfo:ChatRequestInfo,notificationUserId:Int,chatId:Int) -> Future<ChatNotification> {
        
        return requestInfo.dataBase.calculateNumberOfNotifications(notificationUserId: notificationUserId, chatId: chatId).flatMap { notificationCount  in
            
            return self.setChatNotification(requestInfo: requestInfo, notificationUserId: notificationUserId, chatId: chatId, notificationCount: notificationCount)
            }
        
        
    }
    
    private func setChatNotification(requestInfo:ChatRequestInfo,notificationUserId:Int,chatId:Int,notificationCount:Int)-> Future<ChatNotification> {
        
        return requestInfo.dataBase.findChatNotification(notificationUserId: notificationUserId, chatId: chatId).flatMap { foundChatNotification in
            
            var chatNotification:ChatNotification
            if let _chatNotification = foundChatNotification {
                chatNotification = _chatNotification
            } else {
                chatNotification = ChatNotification(userId: notificationUserId, chatId: chatId)
            }
            
            chatNotification.notificationCount = notificationCount
            
            return requestInfo.dataBase.saveChatNotification(chatNotification: chatNotification)
            
            }
    }
    
}

