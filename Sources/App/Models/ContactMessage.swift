//
//  ContactMessage.swift
//  App
//
//  Created by Amir Hossein on 5/22/19.
//

import Vapor


final class ContactMessage: Content {
    var chat: Chat?
    var contactInfo: ContactInfo?
    var textMessages: [TextMessage]?
    var notificationCount: Int?
    
    init(chat: Chat?,textMessages: [TextMessage]?,contactInfo: ContactInfo?,notificationCount: Int?) {
        self.chat = chat
        self.textMessages = textMessages
        self.contactInfo = contactInfo
        self.notificationCount = notificationCount
    }
}


final class ContactInfo: Content {
    var id: Int
    var name: String?
    var image: String?
    
    init(id: Int,name: String?,image: String?) {
        self.id=id
        self.name=name
        self.image=image
    }
}
