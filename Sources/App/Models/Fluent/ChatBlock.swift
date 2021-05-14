//
//  ChatBlock.swift
//  App
//
//  Created by Amir Hossein on 6/25/19.
//

import Vapor
import Fluent
import FluentPostgresDriver


final class ChatBlock : PostgreSQLModel {
    var id:Int?
    var chatId:Int
    var blockedUserId:Int
    var byUserId:Int
    
    init(chatId:Int,blockedUserId:Int,byUserId:Int) {
        self.chatId = chatId
        self.blockedUserId = blockedUserId
        self.byUserId = byUserId
    }
    
    static func find(chatBlock:ChatBlock,conn:DatabaseConnectable) -> EventLoopFuture<ChatBlock?> {
        return ChatBlock.query(on: conn)
            .filter(\.chatId == chatBlock.chatId)
            .filter(\.blockedUserId == chatBlock.blockedUserId)
            .filter(\.byUserId == chatBlock.byUserId)
            .first()
    }
    
}

extension ChatBlock : Migration {}
extension ChatBlock : Content {}
extension ChatBlock : Parameter {}


final class BlockStatus: Content {
    var userIsBlocked: Bool
    var contactIsBlocked: Bool
    
    init(userIsBlocked: Bool, contactIsBlocked: Bool) {
        self.userIsBlocked = userIsBlocked
        self.contactIsBlocked = contactIsBlocked
    }
}
