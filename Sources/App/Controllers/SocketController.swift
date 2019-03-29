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
    
    var allSockets = [Int:[WebSocket]]()
    
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
                self?.allSockets[userId] = []
            }
            self?.allSockets[userId]?.append(ws)
            
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
        case .text:
            guard let textMessages = message.textMessages else {
                return
            }
            self.textMessagesIsReceived(userId: userId, ws: ws, socketDB: socketDB, textMessages: textMessages)
            
        case .control:
            guard let controlMessage = message.controlMessage else {
                return
            }
            self.controlMessageIsReceived(userId: userId, ws: ws, socketDB: socketDB, controlMessage: controlMessage)
        }
        
    }
    
    private func controlMessageIsReceived(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,controlMessage:ControlMessage) {
        
        switch controlMessage.type {
        case .fetch:
            self.fetchMessages(userId: userId, ws: ws, socketDB: socketDB, fetchMessageInput: controlMessage.fetchMessageInput)
        case .ack:
            guard let ackMessage = controlMessage.ackMessage else {
                return
            }
            self.ackMessageIsReceived(userId:userId ,socketDB: socketDB, ackMessage: ackMessage)
        default:
            break
        }
        
    }
    
    private func textMessagesIsReceived(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,textMessages:[TextMessage]){
        
        for textMessage in textMessages {
            socketDB.getChatSenderReceiver(userId:userId,chatId:textMessage.chatId).map { chatSenderReceiver -> Void in
                guard let chatSenderReceiver = chatSenderReceiver else {
                    return
                }
                self.saveTextMessage(userId: userId, ws: ws, socketDB: socketDB, textMessage: textMessage, receiverId: chatSenderReceiver.receiverId)
                }.catch(AppErrorCatch.printError)
        }
        
        
    }
    
    private func ackMessageIsReceived(userId:Int,socketDB:SocketDataBaseController,ackMessage:AckMessage) {
        socketDB.getTextMessage(id: ackMessage.messageId).map { message -> Future<TextMessage> in
            guard let message = message else {
                throw Constants.errors.messageNotFound
            }
            guard message.receiverId == userId else {
                throw Constants.errors.unauthorizedMessage
            }
            message.ack = true
            return socketDB.saveMessage(message: message)
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
    
    private func sendTextMessages(sockets:[WebSocket], textMessages:[TextMessage]) {
        guard textMessages.count != 0 else {
            return
        }
        let message = Message(textMessages:textMessages)
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
    
    private func getReceiverSockets(receiverId:Int) -> [WebSocket]? {
        guard let receiverSockets = self.allSockets[receiverId] else {
            return nil
        }
        return receiverSockets
    }
    
    //MARK: - Save Messages
    
    private func saveTextMessage(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,textMessage:TextMessage,receiverId:Int){
        textMessage.senderId = userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        socketDB.saveMessage(message: textMessage).map { [weak self] textMessage in
            
            self?.sendTextAckMessage(ws: ws, message: textMessage)
            if let receiverSockets = self?.getReceiverSockets(receiverId: receiverId) {
                self?.sendTextMessages(sockets: receiverSockets, textMessages: [textMessage])
            }
            
            }.catch(AppErrorCatch.printError)
    }
    
    //MARK: - Fetch Messages
    
    private func fetchMessages(userId:Int,ws:WebSocket,socketDB:SocketDataBaseController,fetchMessageInput:FetchMessageInput?){
        
        socketDB.getUserChats(userId: userId).map{ chats in
            for chat in chats {
                self.fetchMessages(chat: chat, ws: ws, socketDB: socketDB, fetchMessageInput: fetchMessageInput)
            }
        }.catch(AppErrorCatch.printError)
        
    }
    
    private func fetchMessages(chat:Chat,ws:WebSocket,socketDB:SocketDataBaseController,fetchMessageInput:FetchMessageInput?){
        
        socketDB.getTextMessages(chat: chat, fetchMessageInput: fetchMessageInput).map { textMessages in
            self.sendTextMessages(sockets: [ws], textMessages: textMessages)
            }.catch(AppErrorCatch.printError)
        
    }
    
}

