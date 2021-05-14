//
//  GiftRequest.swift
//  App
//
//  Created by Amir Hossein on 4/1/19.
//

import Vapor
import Fluent

final class GiftRequest: Model {
    
    static let schema = "GiftRequest"
    
    @ID(key: .id)
    var id: Int?
    
    @Field(key: "requestUserId")
    var requestUserId:Int
    
    @Field(key: "giftId")
    var giftId:Int
    
    @Field(key: "giftOwnerId")
    var giftOwnerId:Int
    
    init() {}
    
    init(requestUserId:Int,giftId:Int,giftOwnerId:Int) {
        self.requestUserId=requestUserId
        self.giftId=giftId
        self.giftOwnerId=giftOwnerId
    }
}

extension GiftRequest {
    static func hasExisted(requestUserId:Int,giftId:Int,conn:Database) -> EventLoopFuture<Bool> {
        return GiftRequest.query(on: conn).filter(\.$requestUserId == requestUserId).filter(\.$giftId == giftId).count().map { count in
            if count>0 {
                return true
            }
            return false
        }
    }
    
    static func create(requestUserId:Int,giftId:Int,giftOwnerId:Int,conn:Database) -> EventLoopFuture<GiftRequest>{
        let giftRequest = GiftRequest(requestUserId: requestUserId, giftId: giftId, giftOwnerId: giftOwnerId)
        return giftRequest.save(on: conn).transform(to: giftRequest)
    }
    
    static func getGiftsToDonate(
        userGifts: QueryBuilder<Gift>,
        userId: Int,
        requestUserId: Int) -> QueryBuilder<Gift> {
        return userGifts
            .join(GiftRequest.self, on: \Gift.$id == \GiftRequest.$giftId)
            .filter(GiftRequest.self, \.$giftOwnerId == userId)
            .filter(GiftRequest.self, \.$requestUserId == requestUserId)
    }
}

//extension GiftRequest : Migration {}

extension GiftRequest : Content {}

