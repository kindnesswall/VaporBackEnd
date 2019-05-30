//
//  TextMessage.swift
//  App
//
//  Created by Amir Hossein on 1/28/19.
//

import Vapor
import FluentPostgreSQL


final class TextMessage : PostgreSQLModel {
    var id:Int?
    var chatId:Int
    var senderId:Int?
    var receiverId:Int?
    var text:String
    var ack:Bool?
    var createdAt:Date?
}

extension TextMessage {
    static let createdAtKey: TimestampKey? = \.createdAt
}

extension TextMessage {
    
    static func getTextMessages(chat:Chat,beforeId:Int?,conn:DatabaseConnectable) throws ->Future<[TextMessage]>   {
        
            let query = try chat.textMessages.query(on: conn)
            if let beforeId = beforeId {
                query.filter(\.id < beforeId)
            }
            let maximumCount = Constants.maximumRequestFetchResultsCount
            return query.sort(\.id, PostgreSQLDirection.descending).range(0..<maximumCount).all()
      
    }
    
    static func calculateNumberOfNotifications(userId:Int,chatId:Int,conn:DatabaseConnectable) -> Future<Int> {
        
        let query = TextMessage.query(on: conn)
        
        query.filter(\.chatId == chatId)
            .filter(\.receiverId == userId)
            .filter(\.ack == false)
        
        return query.count()
        
    }
    
}

extension TextMessage : Migration {}
extension TextMessage : Content {}
extension TextMessage : Parameter {}
