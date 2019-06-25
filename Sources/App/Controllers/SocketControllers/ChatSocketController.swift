//
//  ChatSocketController.swift
//  App
//
//  Created by Amir Hossein on 1/26/19.
//

import Vapor


class ChatSocketController {
    
    init() {
        print("init ChatSocketController")
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
            
            let requestInfo = ChatRequestInfo(userId: userId, dataBase: dataBase)
            
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
    
    private func messageIsReceived(requestInfo:ChatRequestInfo,ws:WebSocket,input:String){
        guard let message = try? JSONDecoder().decode(Message.self, from: input.convertToData()) else {
            return
        }
        
        switch message.type {
        case .contact:
            guard let contactMessages = message.contactMessages else {
                return
            }
            self.contactMessagesIsReceived(requestInfo: requestInfo, ws: ws, contactMessages: contactMessages)
        case .control:
            guard let controlMessage = message.controlMessage else {
                return
            }
            self.controlMessageIsReceived(requestInfo: requestInfo, ws: ws, controlMessage: controlMessage)
        }
        
    }
    
    private func controlMessageIsReceived(requestInfo:ChatRequestInfo,ws:WebSocket,controlMessage:ControlMessage) {
        
        switch controlMessage.type {
        case .fetchContact:
            self.fetchContacts(requestInfo: requestInfo, ws: ws)
            break
        case .fetchMessage:
            guard let fetchMessagesInput = controlMessage.fetchMessagesInput else {
                break
            }
            self.fetchMessages(requestInfo: requestInfo, ws: ws, fetchMessagesInput: fetchMessagesInput)
        case .ack:
            guard let ackMessage = controlMessage.ackMessage else {
                break
            }
            let _ = self.chatController.ackMessageIsReceived(requestInfo: requestInfo, ackMessage: ackMessage)
        default:
            break
        }
        
    }
    
    private func contactMessagesIsReceived(requestInfo:ChatRequestInfo,ws:WebSocket,contactMessages:[ContactMessage]){
        
        for contactMessage in contactMessages {
            guard let textMessages = contactMessage.textMessages else {
                return
            }
            textMessagesIsReceived(requestInfo: requestInfo, ws: ws, textMessages: textMessages)
        }
        
    }
    
    private func textMessagesIsReceived(requestInfo:ChatRequestInfo,ws:WebSocket,textMessages:[TextMessage]){
        
        for textMessage in textMessages {
            requestInfo.getChatContacts(chatId:textMessage.chatId).map { chatContacts -> Void in
                self.saveTextMessage(requestInfo: requestInfo, ws: ws, textMessage: textMessage, chat: chatContacts.chat, receiverId: chatContacts.contactId)
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
    
    private func sendTextMessages(requestInfo:ChatRequestInfo,sockets:[WebSocket], textMessages:[TextMessage],chat:Chat,contactInfoId:Int) {
        guard textMessages.count != 0 else {
            return
        }

        chatController.fetchContactInfo(requestInfo: requestInfo, withTextMessages: textMessages, chat: chat, contactInfoId: contactInfoId).map{ [weak self] contactMessage in
            self?.sendContactMessages(sockets: sockets, contactMessages: [contactMessage])
        }.catch(AppErrorCatch.printError)

    }
    
    private func sendContactMessages(sockets:[WebSocket], contactMessages:[ContactMessage]) {
        let message = Message(contactMessages:contactMessages)
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
    
    private func saveTextMessage(requestInfo:ChatRequestInfo,ws:WebSocket,textMessage:TextMessage,chat:Chat,receiverId:Int){
        
        
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
    
    
    private func fetchContacts(requestInfo:ChatRequestInfo,ws:WebSocket){
        
        do {
            try chatController.fetchContacts(requestInfo: requestInfo).map { [weak self] contactMessages in
                self?.sendContactMessages(sockets: [ws], contactMessages: contactMessages)
            }.catch(AppErrorCatch.printError)
            
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
    }
    
    private func fetchMessages(requestInfo:ChatRequestInfo,ws:WebSocket,fetchMessagesInput:FetchMessagesInput){
        
        
        do {
            try chatController.fetchMessages(requestInfo: requestInfo, fetchMessagesInput: fetchMessagesInput).map { fetchResult in
                guard fetchResult.textMessages.count != 0 else {
                    self.sendNoMoreOldMessages(ws: ws, fetchMessagesInput: fetchMessagesInput)
                    return
                }
                self.sendTextMessages(requestInfo: requestInfo, sockets: [ws], textMessages: fetchResult.textMessages, chat: fetchResult.chat, contactInfoId: fetchResult.chatContacts.contactId)
                }.catch(AppErrorCatch.printError)
        } catch {
            AppErrorCatch.printError(error: error)
        }
        
        
    }
    
}
