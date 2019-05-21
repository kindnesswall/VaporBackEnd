//
//  ContactMessage.swift
//  App
//
//  Created by Amir Hossein on 5/22/19.
//

import Foundation


class ContactMessage: Codable {
    var chat: Chat
    var contactName: String?
    var contactImage: String?
    
    init(chat: Chat,contactName: String?,contactImage: String?) {
        self.chat=chat
        self.contactName=contactName
        self.contactImage=contactImage
    }
}
