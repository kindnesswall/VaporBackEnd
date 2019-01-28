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
                
                self?.messageIsReceived(userId: userId, ws: ws, input: input)
                
            })
            
        }).catch({ error in
            print(error.localizedDescription)
            ws.close()
        })
        
    }
    
    
    private func messageIsReceived(userId:Int,ws:WebSocket,input:String){
        guard let message = try? JSONDecoder().decode(Message.self, from: input.convertToData()) else {
            return
        }
        
        switch message.type {
        case .text:
            guard let textMessage = message.textMessage else {
                return
            }
            self.textMessageIsReceived(userId: userId, ws: ws, textMessage: textMessage)
        default:
            break
        }
        
    }
    
    private func textMessageIsReceived(userId:Int,ws:WebSocket,textMessage:TextMessage){
        
        textMessage.senderId = userId
        
        let message = Message(textMessage: textMessage)
        
        sendMessage(receiverId: textMessage.receiverId,message:message)
        
    }
    
    private func sendMessage(receiverId:Int,message:Message){
        
        guard let outputData = try? JSONEncoder().encode(message),
            let outputString = String(bytes: outputData, encoding: .utf8)
            else {
                return
        }
        
        guard let receiverSockets = self.allSockets[receiverId] else {
            return
        }
        
        for socket in receiverSockets {
            socket.send(outputString)
        }
    }
    
    
}
