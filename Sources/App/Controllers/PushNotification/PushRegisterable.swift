
//
//  PushRegisterable.swift
//  
//
//  Created by AmirHossein on 2/14/23.
//

import Vapor
import Fluent

protocol PushRegisterable {
    func registerPush(userId: Int,
                      userToken: Token,
                      input: Inputs.UserPushNotification,
                      on db: Database) -> EventLoopFuture<HTTPStatus>
    func registerPush(userId: Int,
                      userTokenId: UUID,
                      input: Inputs.UserPushNotification,
                      on db: Database) -> EventLoopFuture<HTTPStatus>
}

extension PushRegisterable {
    func registerPush(userId: Int,
                      userToken: Token,
                      input: Inputs.UserPushNotification,
                      on db: Database) -> EventLoopFuture<HTTPStatus> {
        
        guard let userTokenId = userToken.id else {
            return db.makeFailedFuture(.nilTokenId)
        }
        return registerPush(userId: userId, userTokenId: userTokenId, input: input, on: db)
    }
    func registerPush(userId: Int,
                      userTokenId: UUID,
                      input: Inputs.UserPushNotification,
                      on db: Database) -> EventLoopFuture<HTTPStatus> {
        return UserPushNotification.find(
            with: userTokenId,
            or: input,
            on: db).flatMap { items in
                return items.delete(on: db).flatMap {
                    let item = UserPushNotification(
                        userId: userId,
                        userTokenId: userTokenId,
                        input: input)
                    return item.create(on: db)
                        .transform(to: .ok)
                }
            }
    }
}
