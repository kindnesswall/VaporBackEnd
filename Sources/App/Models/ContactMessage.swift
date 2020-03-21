//
//  ContactMessage.swift
//  App
//
//  Created by Amir Hossein on 5/22/19.
//

import Vapor


final class ContactMessage: Content {
    var chatContacts: Chat.ChatContacts
    var textMessages: [TextMessage]?
    var contactProfile: UserProfile?
    var notificationCount: Int?
    var blockStatus: BlockStatus?
    
    var chatId: Int {
        return chatContacts.chatId
    }
    var contactId: Int {
        return chatContacts.contactId
    }
    
    init(chatContacts: Chat.ChatContacts, textMessages: [TextMessage]? = nil, contactProfile: UserProfile? = nil, notificationCount: Int? = nil, blockStatus: BlockStatus? = nil) {
        self.chatContacts = chatContacts
        self.textMessages = textMessages
        self.contactProfile = contactProfile
        self.notificationCount = notificationCount
        self.blockStatus = blockStatus
    }
}

