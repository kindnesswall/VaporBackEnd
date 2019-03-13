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
        
        try AuthWebSocket().isAuthenticated(req: req).map({[weak self] (user) in
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
                
                self?.messageIsReceived(userId: userId, ws: ws, req:req, input: input)
                
            })
            
            self?.sendReadyControlMessage(ws: ws)
            
        }).catch({ error in
            print(error.localizedDescription)
            ws.close()
        })
        
    }
    
    //MARK: - Receive Messages
    
    private func messageIsReceived(userId:Int,ws:WebSocket,req:Request,input:String){
        guard let message = try? JSONDecoder().decode(Message.self, from: input.convertToData()) else {
            return
        }
        
        switch message.type {
        case .text:
            guard let textMessage = message.textMessage else {
                return
            }
            self.textMessageIsReceived(userId: userId, ws: ws, req: req, textMessage: textMessage)
            
        case .control:
            guard let controlMessage = message.controlMessage else {
                return
            }
            self.controlMessageIsReceived(userId: userId, ws: ws, req: req, controlMessage: controlMessage)
        }
        
    }
    
    private func controlMessageIsReceived(userId:Int,ws:WebSocket,req:Request,controlMessage:ControlMessage) {
        
        switch controlMessage.type {
        case .fetch:
            self.fetchMessages(userId: userId, ws: ws, req: req, fetchMessageInput: controlMessage.fetchMessageInput)
        case .ack:
            guard let ackMessage = controlMessage.ackMessage else {
                return
            }
            self.ackMessageIsReceived(userId:userId ,req: req, ackMessage: ackMessage)
        default:
            break
        }
        
    }
    
    private func textMessageIsReceived(userId:Int,ws:WebSocket,req:Request,textMessage:TextMessage){
        
        Chat.getChatSenderReceiver(userId: userId, req: req, chatId: textMessage.chatId).map { chatSenderReceiver -> Void in
            guard let chatSenderReceiver = chatSenderReceiver else {
                return
            }
            self.saveTextMessage(userId: userId, ws: ws, req: req, textMessage: textMessage, receiverId: chatSenderReceiver.receiverId)
        }.catch(AppErrorCatch.printError)
        
    }
    
    private func ackMessageIsReceived(userId:Int,req:Request,ackMessage:AckMessage) {
        TextMessage.find(ackMessage.messageId, on: req).map { message -> Future<TextMessage> in
            guard let message = message else {
                throw Constants.errors.messageNotFound
            }
            guard message.receiverId == userId else {
                throw Constants.errors.unauthorizedMessage
            }
            message.ack = true
            return message.save(on: req)
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
    
    private func sendTextMessage(sockets:[WebSocket], textMessage:TextMessage) {
        let message = Message(textMessage:textMessage)
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
    
    private func saveTextMessage(userId:Int,ws:WebSocket,req:Request,textMessage:TextMessage,receiverId:Int){
        textMessage.senderId = userId
        textMessage.receiverId = receiverId
        textMessage.ack = false
        textMessage.save(on: req).map { [weak self] textMessage in
            
            self?.sendTextAckMessage(ws: ws, message: textMessage)
            if let receiverSockets = self?.getReceiverSockets(receiverId: receiverId) {
                self?.sendTextMessage(sockets: receiverSockets, textMessage: textMessage)
            }
            
            }.catch(AppErrorCatch.printError)
    }
    
    //MARK: - Fetch Messages
    
    private func fetchMessages(userId:Int,ws:WebSocket,req:Request,fetchMessageInput:FetchMessageInput?){
        
        Chat.userChats(userId: userId, req: req).map{ chats in
            for chat in chats {
                self.fetchMessages(chat: chat, ws: ws, req: req, fetchMessageInput: fetchMessageInput)
            }
        }.catch(AppErrorCatch.printError)
        
    }
    
    private func fetchMessages(chat:Chat,ws:WebSocket,req:Request,fetchMessageInput:FetchMessageInput?){
        
        TextMessage.getTextMessages(chat: chat, req: req, fetchMessageInput: fetchMessageInput)?.map { textMessages in
            for textMessage in textMessages {
                self.sendTextMessage(sockets: [ws], textMessage: textMessage)
            }
            }.catch(AppErrorCatch.printError)
        
    }
    
}

