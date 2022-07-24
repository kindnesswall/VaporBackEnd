//
//  GiftRequestController.swift
//  App
//
//  Created by Amir Hossein on 3/13/19.
//

import Vapor
import Fluent

final class GiftRequestController {
    
    func requestGift(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let db = req.db
        let authId = try req.auth.require(User.self)
            .getId()
        let giftId = try req.requireIDParameter()
        
        return Gift.findOrFail(giftId, on: db).flatMap { gift in
            
            guard let giftOwnerId = gift.$user.id else {
                return db.makeFailedFuture(.nilGiftUserId)
            }
            
            guard authId != giftOwnerId else {
                return db.makeFailedFuture(.giftCannotBeDonatedToTheOwner)
            }
            
            guard gift.isReviewed == true else {
                return db.makeFailedFuture(.unreviewedGift)
            }
            
            guard gift.$donatedToUser.id == nil else {
                return db.makeFailedFuture(.giftIsAlreadyDonated)
            }
            
            return GiftRequest.findValidRequest(
                giftId: giftId,
                db: db).flatMap { giftRequest in
                    guard giftRequest == nil else {
                        return db.makeFailedFuture(.giftHasRequest)
                    }
                    return GiftRequest.find(
                        requestUserId: authId,
                        giftId: giftId,
                        db: db).flatMap { giftRequest in
                            if let giftRequest = giftRequest {
                                giftRequest.renew()
                                return giftRequest
                                    .save(on: db)
                                    .transform(to: .ok)
                            } else {
                                return GiftRequest.create(
                                    requestUserId: authId,
                                    giftId: giftId,
                                    giftOwnerId: giftOwnerId,
                                    db: db)
                                .transform(to: .ok)
                            }
                        }
                }
            
        }
    }
    
    func updateRequestStatus(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let db = req.db
        let authId = try req.auth.require(User.self)
            .getId()
        let giftId = try req.requireIDParameter()
        let input = try req
            .content
            .decode(Inputs.GiftRequestStatus.self)
        
        return GiftRequest.findValidRequest(
            requestUserId: authId,
            giftId: giftId,
            db: db)
        .unwrap(or: Abort(.notFoundOrHasExpired))
        .flatMap { giftRequest in
            if let statusDescription = input.statusDescription {
                giftRequest.statusDescription = statusDescription
            }
            switch input.status {
            case .didNotResponse, .wasCenceled:
                giftRequest.status = .wasCenceled
                switch input.status {
                case .didNotResponse:
                    giftRequest.cancellationReason = .didNotResponse
                case .wasCenceled:
                    giftRequest.cancellationReason = .otherReasons
                default:
                    break
                }
                return giftRequest.save(on: db)
                    .transform(to: .ok)
            case .wasReceived:
                giftRequest.status = .wasReceived
                return giftRequest.save(on: db).flatMap {
                    return Gift
                        .findOrFail(giftId, on: db)
                        .flatMap { gift in
                            do {
                                return try gift
                                    .wasReceived(
                                        by: authId, on: db)
                            }
                            catch {
                                return db.makeFailedFuture(error)
                            }
                        }
                }
            }
        }
    }
    
    func getGiftStatus(_ req: Request) throws -> EventLoopFuture<Outputs.GiftStatus> {
        let db = req.db
        let giftId = try req.requireIDParameter()
        return Gift
            .findOrFail(giftId, on: db)
            .flatMap { gift in
                if let donatedToUserId = gift.$donatedToUser.id {
                    return Charity.find(
                        userId: donatedToUserId,
                        on: db).map { charity in
                            return Outputs.GiftStatus(
                                status: .wasReceived,
                                charity: charity)
                        }
                }
                else {
                    return GiftRequest
                        .findValidRequest(
                            giftId: giftId,
                            db: db).flatMap { giftRequest in
                                if let giftRequest = giftRequest {
                                    return Charity
                                        .find(
                                            userId: giftRequest.requestUserId,
                                            on: db).map { charity in
                                                return Outputs.GiftStatus(
                                                    status: .hasRequest,
                                                    charity: charity)
                                            }
                                }
                                else {
                                    return db.makeSucceededFuture(Outputs.GiftStatus(
                                        status: .isAvailable,
                                        charity: nil))
                                }
                            }
                }
            }
    }
}
