//
//  sockets.swift
//  App
//
//  Created by Amir Hossein on 1/26/19.
//

import Vapor


func sockets(wss: NIOWebSocketServer){
    
    let socketController = SocketController()
    
    wss.get("echo", use: socketController.echoFunction)
    
}
