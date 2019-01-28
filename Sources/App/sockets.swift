//
//  sockets.swift
//  App
//
//  Created by Amir Hossein on 1/26/19.
//

import Vapor


func sockets(wss: NIOWebSocketServer){
    
    let uris = URIs();
    
    let socketController = SocketController()
    
    wss.get(uris.chat, use: socketController.socketConnected)
    
}
