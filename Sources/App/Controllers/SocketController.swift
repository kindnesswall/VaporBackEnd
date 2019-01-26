//
//  SocketController.swift
//  App
//
//  Created by Amir Hossein on 1/26/19.
//

import Vapor


class SocketController {
    
    func echoFunction(ws:WebSocket,req:Request) throws {
        
        try AuthWebSocket().isAuthenticated(req: req).map({ (user) in
            print("User: \(user.phoneNumber)")
            // Add a new on text callback
            ws.onText({ (ws, text) in
                // Simply echo any received text
                ws.send(text)
            })
            
        }).catch({ error in
            print(error.localizedDescription)
            ws.close()
        })
        
    }
}
