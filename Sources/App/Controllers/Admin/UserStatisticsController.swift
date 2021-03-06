//
//  UserStatisticsController.swift
//  App
//
//  Created by Amir Hossein on 4/5/19.
//

import Vapor
import FluentPostgreSQL

final class UserStatisticsController {
    
    func usersActiveList(_ req: Request) throws -> Future<[UserStatistic]> {
        
        return try req.content.decode(Inputs.UserQuery.self).flatMap({ queryParam in
            return User.allActiveUsers(on: req, queryParam: queryParam).flatMap({ users in
                return self.getUserStatistics(req: req, users: users)
            })
        })
        
    }
    
    func usersBlockedList(_ req: Request) throws -> Future<[UserStatistic]> {
        return try req.content.decode(Inputs.UserQuery.self).flatMap({ queryParam in
            return User.allBlockedUsers(on: req, queryParam: queryParam).flatMap({ users in
                return self.getUserStatistics(req: req, users: users)
            })
        })
        
    }
    
    func userStatistics(_ req: Request) throws -> Future<UserStatistic> {
        return try req.parameters.next(User.self).flatMap({ user in
            return self.getUserStatistic(req: req, user: user)
        })
    }
    
    func usersChatBlockedList(_ req: Request) throws -> Future<[UserStatistic]> {
        
        return User.allChatBlockedUsers(on: req).map { list in
            return list.map { $0.user }
        }.flatMap({ users in
            return self.getUserStatistics(req: req, users: users)
        })
    }
}

extension UserStatisticsController {
    
    func getUserStatistics(req:Request,users:[User])->Future<[UserStatistic]> {
        
        var list = [Future<UserStatistic>]()

        for user in users {
            let userFuture = self.getUserStatistic(req: req, user: user)
            list.append(userFuture)
        }

        let future = CustomFutureList(req: req, futures: list)
        return future.futureResult()
    }
    
    func getUserStatistic(req:Request,user:User)->Future<UserStatistic> {
        return user.getIdFuture(req: req).flatMap({ userId in
            
            let registeredGifts = Gift.query(on: req, withSoftDeleted: true)
                .filter(\.userId == userId).count()
            let rejectedGifts = Gift.query(on: req, withSoftDeleted: true)
                .filter(\.userId == userId)
                .filter(\.isRejected == true).count()
            
            let donatedGifts = try user.gifts.query(on: req).filter(\.donatedToUserId != nil).count()
            let receivedGifts = try user.receivedGifts.query(on: req).count()
            
            let blockedChats = ChatBlock.query(on: req).filter(\ChatBlock.blockedUserId == userId).count()
            
            return self.getUserStatistic(user: user,
                                         registeredGifts: registeredGifts,
                                         rejectedGifts: rejectedGifts,
                                         donatedGifts: donatedGifts,
                                         receivedGifts: receivedGifts,
                                         blockedChats: blockedChats)
        })
    }
    
    func getUserStatistic(user:User,
                          registeredGifts:Future<Int>,
                          rejectedGifts:Future<Int>,
                          donatedGifts:Future<Int>,
                          receivedGifts:Future<Int>,
                          blockedChats:Future<Int>
        )->Future<UserStatistic> {
        let userStatistic = UserStatistic(user: user)
        return registeredGifts.flatMap { userStatistic.registeredGifts = $0
            return rejectedGifts.flatMap({ userStatistic.rejectedGifts = $0
                return donatedGifts.flatMap({ userStatistic.donatedGifts = $0
                    return receivedGifts.flatMap({ userStatistic.receivedGifts = $0
                        return blockedChats.map({ userStatistic.blockedChats = $0
                            return userStatistic
                        })
                    })
                })
            })
        }
    }
}

