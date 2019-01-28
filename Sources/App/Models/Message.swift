//
//  Message.swift
//  App
//
//  Created by Amir Hossein on 1/27/19.
//

import Foundation

final class Message : Codable {
    var type : MessageType
    var textMessage: TextMessage?
    
    init(textMessage: TextMessage?) {
        self.type = .text
        self.textMessage=textMessage
    }
}

enum MessageType : String,Codable {
    case text
    case fetch
}
