//
//  ChatContacts.swift
//  App
//
//  Created by Amir Hossein on 6/3/20.
//

import Vapor

final class ChatContacts: Content {
    var chatId: Int
    var userId: Int
    var contactId: Int
    
    init(chatId: Int, userId: Int, contactId: Int) {
        self.chatId=chatId
        self.userId=userId
        self.contactId=contactId
    }
}
