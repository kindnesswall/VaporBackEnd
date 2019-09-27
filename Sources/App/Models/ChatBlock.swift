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
    var byUserId:Int
    
    init(chatId:Int,blockedUserId:Int,byUserId:Int) {
        self.chatId = chatId
        self.blockedUserId = blockedUserId
        self.byUserId = byUserId
    }
    
    static func find(chatBlock:ChatBlock,conn:DatabaseConnectable) -> Future<ChatBlock?> {
        return ChatBlock.query(on: conn)
            .filter(\.chatId == chatBlock.chatId)
            .filter(\.blockedUserId == chatBlock.blockedUserId)
            .filter(\.byUserId == chatBlock.byUserId)
            .first()
    }
    
    static func hasFound(chatId:Int,conn:DatabaseConnectable) -> Future<Bool> {
        return ChatBlock.query(on: conn).filter(\.chatId == chatId).count().map({ count in
            return count != 0
        })
    }
    
    static func isChatUnblock(chatId:Int,conn:DatabaseConnectable) throws -> Future<Bool> {
        
        return ChatBlock.hasFound(chatId: chatId, conn: conn).map({ hasFound in
            return !hasFound
        })
    }
    
    static func userBlockedChats(userId:Int,conn:DatabaseConnectable) -> Future<[ChatBlock]> {
        
        return ChatBlock.query(on: conn)
            .filter(\.byUserId == userId)
            .all()
    }
}

extension ChatBlock {
    final class BlockStatus: Content {
        var blockedByUser: Bool?
        var blockedByContact: Bool?
        
        init(blockedByUser:Bool?, blockedByContact:Bool?) {
            self.blockedByUser = blockedByUser
            self.blockedByContact = blockedByContact
        }
    }
    
    static func getChatBlockStatus(userId:Int, chatId:Int, conn:DatabaseConnectable) -> Future<BlockStatus> {
        
        return ChatBlock.query(on: conn)
        .filter(\.chatId == chatId)
        .all()
        .map { chatBlocks in
            
            let blockStatus = BlockStatus(blockedByUser: false, blockedByContact: false)
            
            for chatBlock in chatBlocks {
                if chatBlock.byUserId == userId {
                    blockStatus.blockedByUser = true
                } else {
                    blockStatus.blockedByContact = true
                }
            }
            return blockStatus
        }
    }
}

extension ChatBlock : Migration {}
extension ChatBlock : Content {}
extension ChatBlock : Parameter {}
