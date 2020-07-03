//
//  GiftRequestStatus.swift
//  App
//
//  Created by Amir Hossein on 10/31/19.
//

import Vapor

final class GiftRequestStatus: Content {
    var isRequested: Bool
    var isDonated: Bool?
    var chat: ContactMessage?
    
    enum StatusType {
        case requested(chat: ContactMessage)
        case notRequested
        case donated(chat: ContactMessage)
        case notDonated
    }
    
    init(_ status: StatusType) {
        switch status {
        case .requested(let chat):
            self.isRequested = true
            self.chat = chat
        case .notRequested:
            self.isRequested = false
        case .donated(let chat):
            self.isRequested = false
            self.isDonated = true
            self.chat = chat
        case .notDonated:
            self.isRequested = false
            self.isDonated = false
        }
        
    }
}
