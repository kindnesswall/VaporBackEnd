//
//  ContactMessage.swift
//  App
//
//  Created by Amir Hossein on 5/22/19.
//

import Vapor


final class ContactMessage: Content {
    var chat: Chat?
    var contactInfo: UserProfile?
    var textMessages: [TextMessage]?
    var notificationCount: Int?
    
    init(chat: Chat?,textMessages: [TextMessage]?,contactInfo: UserProfile?,notificationCount: Int?) {
        self.chat = chat
        self.textMessages = textMessages
        self.contactInfo = contactInfo
        self.notificationCount = notificationCount
    }
}

