//
//  ContactMessage.swift
//  App
//
//  Created by Amir Hossein on 5/22/19.
//

import Vapor


final class ContactMessage: Content {
    var chat: ChatContacts
    var textMessages: [TextMessage]?
    var contactProfile: UserProfile?
    var notificationCount: Int
    var blockStatus: BlockStatus
    
    var chatId: Int {
        return chat.chatId
    }
    var contactId: Int {
        return chat.contactId
    }
    
    var isUnblock: Bool {
        return blockStatus.isUnblock
    }
    
    init(chat: ChatContacts, textMessages: [TextMessage]? = nil, contactProfile: UserProfile? = nil, notificationCount: Int, blockStatus: BlockStatus) {
        self.chat = chat
        self.textMessages = textMessages
        self.contactProfile = contactProfile
        self.notificationCount = notificationCount
        self.blockStatus = blockStatus
    }
}

