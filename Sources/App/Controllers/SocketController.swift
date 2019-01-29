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
            self.textMessageIsReceived(userId: userId, req: req, textMessage: textMessage)
            
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
            self.fetchMessages(userId: userId, ws: ws, req: req)
        default:
            break
        }
        
    }
    
    private func textMessageIsReceived(userId:Int,req:Request,textMessage:TextMessage){
        textMessage.senderId = userId
        self.saveTextMessage(textMessage: textMessage, req: req)
        
    }
    
    
    //MARK: - Send Messages
    
    private func sendReadyControlMessage(ws:WebSocket){
        let controlMessage = ControlMessage(type: .ready)
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
    
    private func saveTextMessage(textMessage:TextMessage,req:Request){
        
        textMessage.save(on: req).map { [weak self] textMessage in
            
            guard let receiverSockets = self?.getReceiverSockets(receiverId: textMessage.receiverId) else {
                return
            }
            self?.sendTextMessage(sockets: receiverSockets, textMessage: textMessage)
            
            }.catch(printError)
    }
    
    //MARK: - Fetch Messages
    
    private func fetchMessages(userId:Int,ws:WebSocket,req:Request){
        TextMessage.getTextMessages(userId: userId, req: req).map { textMessages in
            for textMessage in textMessages {
                self.sendTextMessage(sockets: [ws], textMessage: textMessage)
            }
            }.catch(printError)
    }
    
    //MARK: - Error Handling
    
    private func printError(error:Error){
        print(error.localizedDescription)
    }
    
}
