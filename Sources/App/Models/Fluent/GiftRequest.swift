//
//  GiftRequest.swift
//  App
//
//  Created by Amir Hossein on 4/1/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class GiftRequest: PostgreSQLModel {
    var id: Int?
    var requestUserId:Int
    var giftId:Int
    var giftOwnerId:Int
    
    init(requestUserId:Int,giftId:Int,giftOwnerId:Int) {
        self.requestUserId=requestUserId
        self.giftId=giftId
        self.giftOwnerId=giftOwnerId
    }
}

extension GiftRequest {
    static func hasExisted(requestUserId:Int,giftId:Int,conn:DatabaseConnectable) -> EventLoopFuture<Bool> {
        return GiftRequest.query(on: conn).filter(\.requestUserId == requestUserId).filter(\.giftId == giftId).count().map { count in
            if count>0 {
                return true
            }
            return false
        }
    }
    
    static func create(requestUserId:Int,giftId:Int,giftOwnerId:Int,conn:DatabaseConnectable) -> EventLoopFuture<GiftRequest>{
        let giftRequest = GiftRequest(requestUserId: requestUserId, giftId: giftId, giftOwnerId: giftOwnerId)
        return giftRequest.save(on: conn)
    }
    
    static func getGiftsToDonate(userGifts:QueryBuilder<PostgreSQLDatabase, Gift>,userId:Int,requestUserId:Int)-> QueryBuilder<PostgreSQLDatabase, Gift>{
        return userGifts.join(\GiftRequest.giftId, to: \Gift.id).filter(\GiftRequest.giftOwnerId == userId).filter(\GiftRequest.requestUserId == requestUserId)
    }
}

extension GiftRequest : Migration {}

extension GiftRequest : Content {}

extension GiftRequest : Parameter {}
