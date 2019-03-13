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
}

extension TextMessage {
    
    static func getTextMessages(chat:Chat,req:Request,fetchMessageInput:FetchMessageInput?) ->Future<[TextMessage]>?  {
        
        do {
            
            let query = try chat.textMessages.query(on: req)
            if let beforeId = fetchMessageInput?.beforeId {
                query.filter(\.id < beforeId)
            }
            let maximumCount = Constants.maximumRequestFetchResultsCount
            return query.sort(\.id, PostgreSQLDirection.descending).range(0..<maximumCount).all()
            
        } catch _ {
            print("Error in fetching text messages")
            return nil
        }
      
    }
    
}

extension TextMessage : Migration {}
extension TextMessage : Content {}
extension TextMessage : Parameter {}
