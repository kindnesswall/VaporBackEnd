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
            self.fetchContactsInSocket(userId: userId, ws: ws, socketDB: socketDB)
            break
        case .fetchMessage:
            guard let fetchMessagesInput = controlMessage.fetchMessagesInput else {
                break
            }
            self.fetchMessagesInSocket(userId: userId, ws: ws, socketDB: socketDB, fetchMessagesInput: fetchMessagesInput)
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
                self.saveTextMessageInSocket(userId: userId, ws: ws, socketDB: socketDB, textMessage: textMessage, chat: chatContacts.chat, receiverId: chatContacts.contactId)
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

        sendContact(withTextMessages: textMessages, socketDB: socketDB, chat: chat, contactId: contactId).map{ [weak self] contactMessage in
            self?.sendContactMessage(sockets: sockets, contactMessage: contactMessage)
        }.catch(AppErrorCatch.printError)

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
    
    private func saveTextMessageInSocket(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,textMessage:TextMessage,chat:Chat,receiverId:Int){
        
        
        do {
        
        try saveTextMessage(userId: userId, socketDB: socketDB, textMessage: textMessage, chat: chat, receiverId: receiverId).map { [weak self] textMessage  in
            
            self?.sendTextAckMessage(ws: ws, message: textMessage)
            if let receiverSockets = UserSockets.getUserSockets(allSockets: self?.allSockets, userId: receiverId) {
                self?.sendTextMessages(sockets: receiverSockets, socketDB: socketDB, textMessages: [textMessage], chat: chat, contactId: userId)
            }
            
            if let senderOtherSockets = UserSockets.getUserSockets(allSockets: self?.allSockets, userId: userId, excludeSocket: ws) {
                self?.sendTextMessages(sockets: senderOtherSockets, socketDB: socketDB, textMessages: [textMessage], chat: chat, contactId: receiverId)
            }
            
        }.catch(AppErrorCatch.printError)
        
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
        
        
    }
    
    private func saveTextMessage(userId:Int,socketDB:SocketDataBaseController,textMessage:TextMessage,chat:Chat,receiverId:Int) throws -> Future<TextMessage>{
        
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
    
    //MARK: - Fetch Messages
    
    
    private func fetchContactsInSocket(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController){
        
        do {
            try fetchContacts(userId: userId, socketDB: socketDB).map { [weak self] contactMessages in
                for contactMessage in contactMessages {
                    self?.sendContactMessage(sockets: [ws], contactMessage: contactMessage)
                }
            }.catch(AppErrorCatch.printError)
            
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
    }
    
    private func fetchContacts(userId:Int,socketDB:SocketDataBaseController) throws -> Future<[ContactMessage]>{
        
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
    
    private func fetchContact(userId:Int,socketDB:SocketDataBaseController,chat:Chat,contactId:Int) throws ->Future<ContactMessage>{
        
        guard let chatId = chat.id else { throw Constants.errors.nilChatId }
        
        return socketDB.findChatNotification(userId: userId, chatId: chatId).flatMap({ chatNotification in
            guard let chatNotification = chatNotification else { throw Constants.errors.chatNotificationNotFound }
            
            return self.sendContact(withTextMessages: nil, socketDB: socketDB, chat: chat, contactId: contactId, notificationCount: chatNotification.notificationCount)
            
            
        }).catch(AppErrorCatch.printError)
    }
    
    private func sendContact(withTextMessages textMessages: [TextMessage]?,socketDB:SocketDataBaseController,chat:Chat,contactId:Int,notificationCount:Int? = nil)->Future<ContactMessage>{
        
        
        return socketDB.getContactProfile(contactId: contactId).map { contactUser in
            guard let contactUser = contactUser else { throw Constants.errors.contactNotFound }
            let contactInfo = ContactInfo(id: contactId, name: contactUser.name, image: contactUser.image)
            let contactMessage = ContactMessage(chat: chat, textMessages: textMessages, contactInfo: contactInfo, notificationCount: notificationCount)
            return contactMessage

            
        }.catch(AppErrorCatch.printError)
    }
    
    
    private func fetchMessagesInSocket(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,fetchMessagesInput:FetchMessagesInput){
        
        
        do {
            try fetchMessages(userId: userId, ws: ws, socketDB: socketDB, fetchMessagesInput: fetchMessagesInput).map { fetch in
                guard fetch.textMessages.count != 0 else {
                    self.sendNoMoreOldMessages(ws: ws, fetchMessagesInput: fetchMessagesInput)
                    return
                }
                self.sendTextMessages(sockets: [ws], socketDB: socketDB, textMessages: fetch.textMessages, chat: fetch.chat, contactId: fetch.chatContacts.contactId)
                }.catch(AppErrorCatch.printError)
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
        
    }
    
    private func fetchMessages(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,fetchMessagesInput:FetchMessagesInput) throws -> Future<(chat:Chat,chatContacts:Chat.ChatContacts,textMessages:[TextMessage])>{
        
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



