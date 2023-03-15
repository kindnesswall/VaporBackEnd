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
    
    @ID(custom: .id)
    var id: Int?
    
    @Field(key: "requestUserId")
    var requestUserId:Int
    
    @Field(key: "giftId")
    var giftId:Int
    
    @Field(key: "giftOwnerId")
    var giftOwnerId:Int
    
    @OptionalEnum(key: "status")
    var status: Status?
    
    @OptionalField(key: "statusDescription")
    var statusDescription: String?
    
    @OptionalEnum(key: "cancellationReason")
    var cancellationReason: CancellationReason?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    @Timestamp(key: "expiresAt", on: .none)
    var expiresAt: Date?
    
    init() {}
    
    init(requestUserId: Int,
         giftId: Int,
         giftOwnerId: Int
    ) {
        self.requestUserId = requestUserId
        self.giftId = giftId
        self.giftOwnerId = giftOwnerId
        self.status = .isWaiting
        self.expiresAt = Date().addingTimeInterval(86400)
    }
    
    func renew() {
        status = .isWaiting
        expiresAt = Date().addingTimeInterval(86400)
    }
    
    enum Status: String, Codable {
        case isWaiting
        case wasReceived
        case wasCenceled
    }
    
    enum CancellationReason: String, Codable {
        case didNotResponse
        case otherReasons
    }
}

extension GiftRequest {
    
    static func findValidRequest(
        giftId: Int,
        db: Database) -> EventLoopFuture<GiftRequest?> {
            return GiftRequest
                .query(on: db)
                .filter(\.$giftId == giftId)
                .filter(\.$status == .isWaiting)
                .filter(\.$expiresAt > Date())
                .first()
        }
    
    static func findQuery(requestUserId: Int,
                          giftId: Int,
                          db: Database) -> QueryBuilder<GiftRequest> {
        return GiftRequest
            .query(on: db)
            .filter(\.$requestUserId == requestUserId)
            .filter(\.$giftId == giftId)
    }
    
    static func find(requestUserId: Int,
                     giftId: Int,
                     db: Database) -> EventLoopFuture<GiftRequest?> {
        return findQuery(
            requestUserId: requestUserId,
            giftId: giftId,
            db: db)
        .first()
    }
    
    static func findValidRequest(
        requestUserId: Int,
        giftId: Int,
        db: Database) -> EventLoopFuture<GiftRequest?> {
            return findQuery(
                requestUserId: requestUserId,
                giftId: giftId,
                db: db)
            .filter(\.$status == .isWaiting)
            .filter(\.$expiresAt > Date())
            .first()
        }
    
    static func create(requestUserId: Int,
                       giftId: Int,
                       giftOwnerId: Int,
                       db: Database) -> EventLoopFuture<GiftRequest> {
        let object = GiftRequest(
            requestUserId: requestUserId,
            giftId: giftId,
            giftOwnerId: giftOwnerId
        )
        return object
            .create(on: db)
            .transform(to: object)
    }
}

extension GiftRequest {
    
    static func getUserRequestedGiftsQuery(requestUserId: Int,
                                      db: Database) -> QueryBuilder<Gift> {
        return Gift
            .query(on: db)
            .filter(\.$deletedAt == nil) //TODO: Is it needed?
            .filter(\.$isReviewed == true)
            .filter(\.$isRejected == false)
            .join(GiftRequest.self, on: \Gift.$id == \GiftRequest.$giftId)
            .filter(GiftRequest.self, \.$requestUserId == requestUserId)
            .filter(GiftRequest.self, \GiftRequest.$status == .isWaiting)
            .filter(GiftRequest.self, \GiftRequest.$expiresAt > Date())
    }
    
}

//extension GiftRequest : Migration {}

extension GiftRequest : Content {}

