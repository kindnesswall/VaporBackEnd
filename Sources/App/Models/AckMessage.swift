//
//  AckMessage.swift
//  App
//
//  Created by Amir Hossein on 3/11/19.
//

import Vapor

final class AckMessage: Content {
    var messageId:Int
    var textMessage:TextMessage?
    
    init(messageId:Int) {
        self.messageId=messageId
    }
    init?(textMessage:TextMessage) {
        guard let messageId = textMessage.id else {
            return nil
        }
        self.messageId=messageId
        self.textMessage=textMessage
    }
}
