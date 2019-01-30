//
//  ControlMessage.swift
//  App
//
//  Created by Amir Hossein on 1/29/19.
//

import Foundation

final class ControlMessage : Codable {
    var type:ControlMessageType
    var fetchMessage:FetchMessage?
    
    init(type:ControlMessageType) {
        self.type=type
    }
    init(fetchMessage:FetchMessage) {
        self.type = .fetch
        self.fetchMessage=fetchMessage
    }
}

enum ControlMessageType : String,Codable {
    case ready
    case fetch
}
