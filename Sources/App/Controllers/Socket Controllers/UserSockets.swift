//
//  UserSockets.swift
//  App
//
//  Created by Amir Hossein on 3/29/19.
//

import Vapor

class UserSockets {
    
    private(set) var sockets = [WebSocket]()
    
    private var lastSocketIndex = -1
    
    func addSocket(socket:WebSocket){
        if sockets.count < Constants.maximumActiveSocketsPerUser {
            sockets.append(socket)
        } else {
            let index = (lastSocketIndex+1) % sockets.count
            sockets[index] = socket
        }
        lastSocketIndex = (lastSocketIndex+1) % sockets.count
    }
    
}

extension UserSockets {
    static func getUserSockets(allSockets:[Int:UserSockets]?,userId:Int,excludeSocket:WebSocket?=nil) -> [WebSocket]? {
        
        guard var userSockets = allSockets?[userId]?.sockets else {
            return nil
        }
        
        if let excludeSocket = excludeSocket {
            userSockets.removeAll { socket -> Bool in
                if socket === excludeSocket { return true }
                return false
            }
        }
        
        return userSockets
    }
}
