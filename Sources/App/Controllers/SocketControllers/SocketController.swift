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
    
    let chatController = ChatController()
    
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
            self.chatController.ackMessageIsReceived(userId:userId ,socketDB: socketDB, ackMessage: ackMessage)
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

        chatController.fetchContactInfo(withTextMessages: textMessages, socketDB: socketDB, chat: chat, contactId: contactId).map{ [weak self] contactMessage in
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
        
        try chatController.saveTextMessage(userId: userId, socketDB: socketDB, textMessage: textMessage, chat: chat, receiverId: receiverId).map { [weak self] textMessage  in
            
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
    
    
    
    //MARK: - Fetch Messages
    
    
    private func fetchContactsInSocket(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController){
        
        do {
            try chatController.fetchContacts(userId: userId, socketDB: socketDB).map { [weak self] contactMessages in
                for contactMessage in contactMessages {
                    self?.sendContactMessage(sockets: [ws], contactMessage: contactMessage)
                }
            }.catch(AppErrorCatch.printError)
            
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
    }
    
    
    
    
    private func fetchMessagesInSocket(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,fetchMessagesInput:FetchMessagesInput){
        
        
        do {
            try chatController.fetchMessages(userId: userId, ws: ws, socketDB: socketDB, fetchMessagesInput: fetchMessagesInput).map { fetch in
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
    
    
    
    
    
    
}





