//
//  TextMessage.swift
//  App
//
//  Created by Amir Hossein on 1/28/19.
//

import Vapor
import Fluent
import FluentPostgresDriver


final class TextMessage : PostgreSQLModel {
    var id:Int?
    var chatId:Int
    var senderId:Int?
    var receiverId:Int?
    var text:String
    var type: String?
    var ack:Bool?
    var createdAt:Date?
    
    init(input: Inputs.TextMessage) throws {
        self.chatId = input.chatId
        self.text = input.text
        
        if let rawType = input.type {
            guard let type = TypeCases(rawValue: rawType) else {
                throw Abort(.invalidType)
            }
            self.type = type.rawValue
        }
    }
}

extension TextMessage {
    enum TypeCases: String {
        case giftRequest
        case giftDonation
    }
}

extension TextMessage {
    static let createdAtKey: TimestampKey? = \.createdAt
}

extension TextMessage: PushPayloadable {
    var pushMainPath: String { return "chat" }
    var pushSupplementPath: String? { return "/message" }
    var pushQueryItems: [URLQueryItem] { return [] }
    var pushContentName: String? { return "message" }
}

extension TextMessage {
    
    static func calculateNumberOfNotifications(userId:Int,chatId:Int,conn:DatabaseConnectable) -> EventLoopFuture<Int> {
        
        let query = TextMessage.query(on: conn)
        
        query.filter(\.chatId == chatId)
            .filter(\.receiverId == userId)
            .filter(\.ack == false)
        
        return query.count()
        
    }
    
}

//extension TextMessage : Migration {}
extension TextMessage : Content {}
extension TextMessage : Parameter {}
