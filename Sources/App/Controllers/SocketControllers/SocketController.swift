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
        
        let dataBase = ChatDataBase(req: req)
        
        guard let bearerAuthorization = req.http.headers.bearerAuthorization else {
            throw Constants.errors.unauthorizedSocket
        }
        
        try AuthWebSocket().isAuthenticated(bearerAuthorization: bearerAuthorization, dataBase: dataBase).map({[weak self] (user) in
            print("User: \(user.id?.description ?? "") is connected with socket")
            
            guard let userId = user.id else {
                throw Constants.errors.nilUserId
            }
            
            if self?.allSockets[userId] == nil {
                self?.allSockets[userId] = UserSockets()
            }
            self?.allSockets[userId]?.addSocket(socket: ws)
            
            let requestInfo = ChatController.RequestInfo(userId: userId, dataBase: dataBase)
            
            // Add a new on text callback
            ws.onText({ [weak self] (ws, input) in
                
                self?.messageIsReceived(requestInfo: requestInfo, ws: ws, input: input)
                
            })
            
            self?.sendReadyControlMessage(ws: ws)
            
        }).catch({ error in
            print(error.localizedDescription)
            ws.close()
        })
        
    }
    
    //MARK: - Receive Messages
    
    private func messageIsReceived(requestInfo:ChatController.RequestInfo,ws:WebSocket,input:String){
        guard let message = try? JSONDecoder().decode(Message.self, from: input.convertToData()) else {
            return
        }
        
        switch message.type {
        case .contact:
            guard let contactMessage = message.contactMessage else {
                return
            }
            self.contactMessageIsReceived(requestInfo: requestInfo, ws: ws, contactMessage: contactMessage)
        case .control:
            guard let controlMessage = message.controlMessage else {
                return
            }
            self.controlMessageIsReceived(requestInfo: requestInfo, ws: ws, controlMessage: controlMessage)
        }
        
    }
    
    private func controlMessageIsReceived(requestInfo:ChatController.RequestInfo,ws:WebSocket,controlMessage:ControlMessage) {
        
        switch controlMessage.type {
        case .fetchContact:
            self.fetchContactsInSocket(requestInfo: requestInfo, ws: ws)
            break
        case .fetchMessage:
            guard let fetchMessagesInput = controlMessage.fetchMessagesInput else {
                break
            }
            self.fetchMessagesInSocket(requestInfo: requestInfo, ws: ws, fetchMessagesInput: fetchMessagesInput)
        case .ack:
            guard let ackMessage = controlMessage.ackMessage else {
                break
            }
            self.chatController.ackMessageIsReceived(requestInfo: requestInfo, ackMessage: ackMessage)
        default:
            break
        }
        
    }
    
    private func contactMessageIsReceived(requestInfo:ChatController.RequestInfo,ws:WebSocket,contactMessage:ContactMessage){
        guard let textMessages = contactMessage.textMessages else {
            return
        }
        textMessagesIsReceived(requestInfo: requestInfo, ws: ws, textMessages: textMessages)
    }
    
    private func textMessagesIsReceived(requestInfo:ChatController.RequestInfo,ws:WebSocket,textMessages:[TextMessage]){
        
        for textMessage in textMessages {
            requestInfo.dataBase.getChatContacts(userId:requestInfo.userId,chatId:textMessage.chatId).map { chatContacts -> Void in
                guard let chatContacts = chatContacts else {
                    return
                }
                self.saveTextMessageInSocket(requestInfo: requestInfo, ws: ws, textMessage: textMessage, chat: chatContacts.chat, receiverId: chatContacts.contactId)
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
    
    private func sendTextMessages(requestInfo:ChatController.RequestInfo,sockets:[WebSocket], textMessages:[TextMessage],chat:Chat,contactInfoId:Int) {
        guard textMessages.count != 0 else {
            return
        }

        chatController.fetchContactInfo(requestInfo: requestInfo, withTextMessages: textMessages, chat: chat, contactId: contactInfoId).map{ [weak self] contactMessage in
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
    
    private func saveTextMessageInSocket(requestInfo:ChatController.RequestInfo,ws:WebSocket,textMessage:TextMessage,chat:Chat,receiverId:Int){
        
        
        do {
        
            try chatController.saveTextMessage(requestInfo: requestInfo, textMessage: textMessage, chat: chat, receiverId: receiverId).map { [weak self] textMessage  in
            
            self?.sendTextAckMessage(ws: ws, message: textMessage)
            if let receiverSockets = UserSockets.getUserSockets(allSockets: self?.allSockets, userId: receiverId) {
                self?.sendTextMessages(requestInfo: requestInfo, sockets: receiverSockets, textMessages: [textMessage], chat: chat, contactInfoId: requestInfo.userId)
            }
            
            if let senderOtherSockets = UserSockets.getUserSockets(allSockets: self?.allSockets, userId: requestInfo.userId, excludeSocket: ws) {
                self?.sendTextMessages(requestInfo: requestInfo, sockets: senderOtherSockets, textMessages: [textMessage], chat: chat, contactInfoId: receiverId)
            }
            
        }.catch(AppErrorCatch.printError)
        
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
        
        
    }
    
    
    
    //MARK: - Fetch Messages
    
    
    private func fetchContactsInSocket(requestInfo:ChatController.RequestInfo,ws:WebSocket){
        
        do {
            try chatController.fetchContacts(requestInfo: requestInfo).map { [weak self] contactMessages in
                for contactMessage in contactMessages {
                    self?.sendContactMessage(sockets: [ws], contactMessage: contactMessage)
                }
            }.catch(AppErrorCatch.printError)
            
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
    }
    
    
    
    
    private func fetchMessagesInSocket(requestInfo:ChatController.RequestInfo,ws:WebSocket,fetchMessagesInput:FetchMessagesInput){
        
        
        do {
            try chatController.fetchMessages(requestInfo: requestInfo, fetchMessagesInput: fetchMessagesInput).map { fetch in
                guard fetch.textMessages.count != 0 else {
                    self.sendNoMoreOldMessages(ws: ws, fetchMessagesInput: fetchMessagesInput)
                    return
                }
                self.sendTextMessages(requestInfo: requestInfo, sockets: [ws], textMessages: fetch.textMessages, chat: fetch.chat, contactInfoId: fetch.chatContacts.contactId)
                }.catch(AppErrorCatch.printError)
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
        
    }
    
    
    
    
    
    
}





