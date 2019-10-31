//
//  RequestStatus.swift
//  App
//
//  Created by Amir Hossein on 10/31/19.
//

import Vapor

final class RequestStatus: Content {
    var isRequested: Bool
    var chat: Chat?
    
    init(isRequested: Bool, chat: Chat?) {
        self.isRequested = isRequested
        self.chat = chat
    }
}
