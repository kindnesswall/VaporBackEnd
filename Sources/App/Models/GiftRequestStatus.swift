//
//  GiftRequestStatus.swift
//  App
//
//  Created by Amir Hossein on 10/31/19.
//

import Vapor

final class GiftRequestStatus: Content {
    var isRequested: Bool
    var chat: ContactMessage?
    
    init(isRequested: Bool, chat: ContactMessage?) {
        self.isRequested = isRequested
        self.chat = chat
    }
}
