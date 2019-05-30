//
//  SocketController.swift
//  App
//
//  Created by Amir Hossein on 1/26/19.
//

import Vapor


class SocketController {
    
    init() {
        print("init SocketController")
    }
    
    var allSockets = [Int:UserSockets]()
    
    func socketConnected(ws:WebSocket,req:Request) throws {
        
        let socketDB = SocketDataBaseController(req: req)
        
        guard let bearerAuthorization = req.http.headers.bearerAuthorization else {
            throw Constants.errors.unauthorizedSocket
        }
        
        try AuthWebSocket().isAuthenticated(bearerAuthorization: bearerAuthorization, socketDB: socketDB).map({[weak self] (user) in
            print("User: \(user.id?.description ?? "") is connected with socket")
            
            guard let userId = user.id else {
                throw Constants.errors.nilUserId
            }
            
            if self?.allSockets[userId] == nil {
                self?.allSockets[userId] = UserSockets()
            }
            self?.allSockets[userId]?.addSocket(socket: ws)
            
            // Add a new on text callback
            ws.onText({ [weak self] (ws, input) in
                
                self?.messageIsReceived(userId: userId, ws: ws, socketDB: socketDB, input: input)
                
            })
            
            self?.sendReadyControlMessage(ws: ws)
            
        }).catch({ error in
            print(error.localizedDescription)
            ws.close()
        })
        
    }
    
    //MARK: - Receive Messages
    
    private func messageIsReceived(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,input:String){
        guard let message = try? JSONDecoder().decode(Message.self, from: input.convertToData()) else {
            return
        }
        
        switch message.type {
        case .contact:
            guard let contactMessage = message.contactMessage else {
                return
            }
            self.contactMessageIsReceived(userId: userId, ws: ws, socketDB: socketDB, contactMessage: contactMessage)
        case .control:
            guard let controlMessage = message.controlMessage else {
                return
            }
            self.controlMessageIsReceived(userId: userId, ws: ws, socketDB: socketDB, controlMessage: controlMessage)
        }
        
    }
    
    private func controlMessageIsReceived(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,controlMessage:ControlMessage) {
        
        switch controlMessage.type {
        case .fetchContact:
            self.fetchContacts(userId: userId, ws: ws, socketDB: socketDB)
            break
        case .fetchMessage:
            guard let fetchMessagesInput = controlMessage.fetchMessagesInput else {
                break
            }
            self.fetchMessages(userId: userId, ws: ws, socketDB: socketDB, fetchMessagesInput: fetchMessagesInput)
        case .ack:
            guard let ackMessage = controlMessage.ackMessage else {
                break
            }
            self.ackMessageIsReceived(userId:userId ,socketDB: socketDB, ackMessage: ackMessage)
        default:
            break
        }
        
    }
    
    private func contactMessageIsReceived(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,contactMessage:ContactMessage){
        guard let textMessages = contactMessage.textMessages else {
            return
        }
        textMessagesIsReceived(userId: userId, ws: ws, socketDB: socketDB, textMessages: textMessages)
    }
    
    private func textMessagesIsReceived(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,textMessages:[TextMessage]){
        
        for textMessage in textMessages {
            socketDB.getChatContacts(userId:userId,chatId:textMessage.chatId).map { chatContacts -> Void in
                guard let chatContacts = chatContacts else {
                    return
                }
                self.saveTextMessage(userId: userId, ws: ws, socketDB: socketDB, textMessage: textMessage, chat: chatContacts.chat, receiverId: chatContacts.contactId)
                }.catch(AppErrorCatch.printError)
        }
        
        
    }
    
    private func ackMessageIsReceived(userId:Int,socketDB:SocketDataBaseController,ackMessage:AckMessage) {
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
    
    
    //MARK: - Send Messages
    
    private func sendReadyControlMessage(ws:WebSocket){
        let controlMessage = ControlMessage(type: .ready)
        let message = Message(controlMessage: controlMessage)
        self.sendMessage(sockets: [ws], message: message)
    }
    
    private func sendTextAckMessage(ws:WebSocket,message:TextMessage) {
        guard let ackMessage = AckMessage(textMessage: message) else {
            return
        }
        let controlMessage = ControlMessage(ackMessage: ackMessage)
        let message = Message(controlMessage: controlMessage)
        self.sendMessage(sockets: [ws], message: message)
    }
    
    private func sendTextMessages(sockets:[WebSocket],socketDB:SocketDataBaseController, textMessages:[TextMessage],chat:Chat,contactId:Int) {
        guard textMessages.count != 0 else {
            return
        }
        
        sendContact(withTextMessages: textMessages, sockets: sockets, socketDB: socketDB, chat: chat, contactId: contactId)
        
    }
    
    private func sendContactMessage(sockets:[WebSocket], contactMessage:ContactMessage) {
        let message = Message(contactMessage:contactMessage)
        sendMessage(sockets:sockets , message:message)
    }
    
    private func sendMessage(sockets:[WebSocket], message:Message){
        
        guard let outputData = try? JSONEncoder().encode(message),
            let outputString = String(bytes: outputData, encoding: .utf8)
            else {
                return
        }
        
        for socket in sockets {
            socket.send(outputString)
        }
        
    }
    
    private func sendNoMoreOldMessages(ws:WebSocket,fetchMessagesInput:FetchMessagesInput){
        let controlMessage = ControlMessage(type: .noMoreOldMessages, fetchMessagesInput: fetchMessagesInput)
        let message = Message(controlMessage: controlMessage)
        self.sendMessage(sockets: [ws], message: message)
    }
    
    //MARK: - Save Messages
    
    private func saveTextMessage(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,textMessage:TextMessage,chat:Chat,receiverId:Int){
        
        textMessage.senderId = userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        
        guard let chatId = chat.id else {
            return
        }
        
        socketDB.saveMessage(message: textMessage).map { [weak self] textMessage in
            
            self?.updateChatNotification(userId: receiverId, chatId: chatId, socketDB: socketDB)
            self?.sendTextAckMessage(ws: ws, message: textMessage)
            if let receiverSockets = UserSockets.getUserSockets(allSockets: self?.allSockets, userId: receiverId) {
                
                self?.sendTextMessages(sockets: receiverSockets, socketDB: socketDB, textMessages: [textMessage], chat: chat, contactId: userId)
            }
            if let senderOtherSockets = UserSockets.getUserSockets(allSockets: self?.allSockets, userId: userId, excludeSocket: ws) {
                self?.sendTextMessages(sockets: senderOtherSockets, socketDB: socketDB, textMessages: [textMessage], chat: chat, contactId: receiverId)
            }
            
            }.catch(AppErrorCatch.printError)
    }
    
    //MARK: - Fetch Messages
    
    private func fetchContacts(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController){
        
        socketDB.getUserChats(userId: userId).map{ chats in
            for chat in chats {
                guard let chatContacts = Chat.getChatContacts(userId: userId, chat: chat) else {
                    continue
                }
                
                self.fetchContact(userId: userId, ws: ws, socketDB: socketDB, chat: chat, contactId: chatContacts.contactId)
                
            }
            }.catch(AppErrorCatch.printError)
        
    }
    
    private func fetchContact(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,chat:Chat,contactId:Int){
        
        guard let chatId = chat.id else { return }
        
        socketDB.findChatNotification(userId: userId, chatId: chatId).map({ chatNotification in
            guard let chatNotification = chatNotification else { return }
            
            self.sendContact(withTextMessages: nil, sockets: [ws], socketDB: socketDB, chat: chat, contactId: contactId, notificationCount: chatNotification.notificationCount)
            
            
        }).catch(AppErrorCatch.printError)
    }
    
    private func sendContact(withTextMessages textMessages: [TextMessage]?,sockets:[WebSocket],socketDB:SocketDataBaseController,chat:Chat,contactId:Int,notificationCount:Int? = nil){
        
        
        socketDB.getContactProfile(contactId: contactId).map { contactUser in
            guard let contactUser = contactUser else { return }
            let contactInfo = ContactInfo(id: contactId, name: contactUser.name, image: contactUser.image)
            
                let contactMessage = ContactMessage(chat: chat, textMessages: textMessages, contactInfo: contactInfo, notificationCount: notificationCount)
                self.sendContactMessage(sockets: sockets, contactMessage: contactMessage)
            
        }.catch(AppErrorCatch.printError)
    }
    
    private func fetchMessages(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,fetchMessagesInput:FetchMessagesInput){
        
        socketDB.getChat(chatId: fetchMessagesInput.chatId).map { chat in
            guard let chat = chat else { return }
            guard Chat.isUserChat(userId: userId, chat: chat) else {
                print(Constants.errors.unauthorizedRequest.debugDescription)
                return
            }
            guard let chatContacts = Chat.getChatContacts(userId: userId, chat: chat) else {
                return
            }
            
            self.fetchMessages(chat: chat, beforeId: fetchMessagesInput.beforeId, ws: ws, socketDB: socketDB, contactId: chatContacts.contactId, onEmptyList:{
                self.sendNoMoreOldMessages(ws: ws, fetchMessagesInput: fetchMessagesInput)
            })
            
        }.catch(AppErrorCatch.printError)
        
    }
    
    private func fetchMessages(chat:Chat,beforeId:Int?,ws:WebSocket,socketDB:SocketDataBaseController,contactId:Int,onEmptyList:(()->Void)?=nil){
        
        socketDB.getTextMessages(chat: chat, beforeId: beforeId).map { textMessages in
            guard textMessages.count != 0 else {
                onEmptyList?()
                return
            }
            self.sendTextMessages(sockets: [ws], socketDB: socketDB, textMessages: textMessages, chat: chat, contactId: contactId)
            }.catch(AppErrorCatch.printError)
        
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





