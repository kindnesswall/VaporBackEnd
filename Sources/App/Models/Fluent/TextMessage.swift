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
    
    @ID(custom: .id)
    var id:Int?
    
    @Parent(key: "chatId")
    var chat: DirectChat
    
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
        self.$chat.id = input.chatId
        self.text = input.text
        
        if let rawType = input.type {
            guard let type = TypeCases(rawValue: rawType) else {
                throw Abort(.invalidType)
            }
            self.type = type.rawValue
        }
    }
    
    var outputObject: Output {
        .init(
            id: id,
            chatId: $chat.id,
            senderId: senderId,
            receiverId: receiverId,
            text: text,
            type: type,
            ack: ack,
            createdAt: createdAt)
    }
    
    struct Output: Content {
        let id:Int?
        let chatId:Int
        let senderId:Int?
        let receiverId:Int?
        let text:String
        let type: String?
        let ack:Bool?
        let createdAt:Date?
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
        
        query.filter(\.$chat.$id == chatId)
            .filter(\.$receiverId == userId)
            .filter(\.$ack == false)
        
        return query.count()
        
    }
    
}

//extension TextMessage : Migration {}
extension TextMessage : Content {}

extension Array where Element == TextMessage {
    var outputArray: [TextMessage.Output] {
        map { $0.outputObject }
    }
}

extension EventLoopFuture where Value == TextMessage {
    var outputObject: EventLoopFuture<TextMessage.Output> {
        map { $0.outputObject }
    }
}
