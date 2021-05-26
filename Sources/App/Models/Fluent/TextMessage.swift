//
//  TextMessage.swift
//  App
//
//  Created by Amir Hossein on 1/28/19.
//

import Vapor
import Fluent

final class TextMessage : Model {
    
    static let schema = "TextMessage"
    
    @ID(key: .id)
    var id:Int?
    
    @Field(key: "chatId")
    var chatId:Int
    
    @OptionalField(key: "senderId")
    var senderId:Int?
    
    @OptionalField(key: "receiverId")
    var receiverId:Int?
    
    @Field(key: "text")
    var text:String
    
    @OptionalField(key: "type")
    var type: String?
    
    @OptionalField(key: "ack")
    var ack:Bool?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    init() {}
    
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

extension TextMessage: PushPayloadable {
    var pushMainPath: String { return "chat" }
    var pushSupplementPath: String? { return "/message" }
    var pushQueryItems: [URLQueryItem] { return [] }
    var pushContentName: String? { return "message" }
}

extension TextMessage {
    
    static func calculateNumberOfNotifications(userId:Int,chatId:Int,conn:Database) -> EventLoopFuture<Int> {
        
        let query = TextMessage.query(on: conn)
        
        query.filter(\.chatId == chatId)
            .filter(\.receiverId == userId)
            .filter(\.ack == false)
        
        return query.count()
        
    }
    
}

//extension TextMessage : Migration {}
extension TextMessage : Content {}

