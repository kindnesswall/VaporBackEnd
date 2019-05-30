//
//  ChatNotification.swift
//  App
//
//  Created by Amir Hossein on 5/28/19.
//

import Vapor
import FluentPostgreSQL

final class ChatNotification: PostgreSQLModel {
    var id:Int?
    var userId:Int
    var chatId:Int
    var notificationCount:Int = 0
    
    init(userId:Int,chatId:Int) {
        self.userId=userId
        self.chatId=chatId
    }
}

extension ChatNotification {
    
    static func find(userId:Int,chatId:Int,conn:DatabaseConnectable) -> Future<ChatNotification?> {
        return ChatNotification.query(on: conn).filter(\.userId == userId).filter(\.chatId == chatId).first()
    }
    
}

extension ChatNotification : Migration {}

extension ChatNotification : Content {}

extension ChatNotification : Parameter {}
