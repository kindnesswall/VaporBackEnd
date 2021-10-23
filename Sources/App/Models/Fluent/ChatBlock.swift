//
//  ChatBlock.swift
//  App
//
//  Created by Amir Hossein on 6/25/19.
//

import Vapor
import Fluent

final class ChatBlock : Model {
    
    static let schema = "ChatBlock"
    
    @ID(custom: .id)
    var id:Int?
    
    @Field(key: "chatId")
    var chatId:Int
    
    @Field(key: "blockedUserId")
    var blockedUserId:Int
    
    @Field(key: "byUserId")
    var byUserId:Int
    
    init() {}
    
    init(chatId:Int,blockedUserId:Int,byUserId:Int) {
        self.chatId = chatId
        self.blockedUserId = blockedUserId
        self.byUserId = byUserId
    }
    
    static func find(chatBlock:ChatBlock,conn:Database) -> EventLoopFuture<ChatBlock?> {
        return ChatBlock.query(on: conn)
            .filter(\.$chatId == chatBlock.chatId)
            .filter(\.$blockedUserId == chatBlock.blockedUserId)
            .filter(\.$byUserId == chatBlock.byUserId)
            .first()
    }
    
}

//extension ChatBlock : Migration {}
extension ChatBlock : Content {}


final class BlockStatus: Content {
    var userIsBlocked: Bool
    var contactIsBlocked: Bool
    
    init(userIsBlocked: Bool, contactIsBlocked: Bool) {
        self.userIsBlocked = userIsBlocked
        self.contactIsBlocked = contactIsBlocked
    }
}
