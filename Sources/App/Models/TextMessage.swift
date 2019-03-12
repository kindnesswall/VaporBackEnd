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
    var senderId:Int
    var text:String
    var receiverId:Int
    var ack:Bool?
}

extension TextMessage {
    
    static func getTextMessages(userId:Int,req:Request,afterId:Int?)->Future<[TextMessage]> {
        let query = TextMessage.query(on: req).group(.or) {
            $0.filter(\.senderId == userId).filter(\.receiverId == userId)
            }
        if let afterId = afterId {
            query.filter(\.id > afterId)
        }
        return query.all()
    }
    
}

extension TextMessage : Migration {}
extension TextMessage : Content {}
extension TextMessage : Parameter {}
