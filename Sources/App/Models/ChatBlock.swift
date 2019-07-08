//
//  ChatBlock.swift
//  App
//
//  Created by Amir Hossein on 6/25/19.
//

import Vapor
import FluentPostgreSQL


final class ChatBlock : PostgreSQLModel {
    var id:Int?
    var chatId:Int
    var blockedUserId:Int
    
    init(chatId:Int,blockedUserId:Int) {
        self.chatId = chatId
        self.blockedUserId = blockedUserId
    }
    
    static func find(chatBlock:ChatBlock,conn:DatabaseConnectable) -> Future<ChatBlock?> {
        return ChatBlock.query(on: conn)
            .filter(\.chatId == chatBlock.chatId)
            .filter(\.blockedUserId == chatBlock.blockedUserId).first()
    }
    
    static func hasFound(chatId:Int,conn:DatabaseConnectable) -> Future<Bool> {
        return ChatBlock.query(on: conn).filter(\.chatId == chatId).count().map({ count in
            return count != 0
        })
    }
    
    static func isChatUnblock(chat:Chat,conn:DatabaseConnectable) throws -> Future<Bool> {
        guard let chatId = chat.id else {
            throw Constants.errors.nilChatId
        }
        
        return ChatBlock.hasFound(chatId: chatId, conn: conn).map({ hasFound in
            return !hasFound
        })
    }
}

extension ChatBlock : Migration {}
extension ChatBlock : Content {}
extension ChatBlock : Parameter {}