//
//  UserAdminController.swift
//  App
//
//  Created by Amir Hossein on 4/5/19.
//

import Vapor
import FluentPostgreSQL

final class UserAdminController {
    
    func usersActiveList(_ req: Request) throws -> Future<[UserStatistic]> {
        
        return try req.content.decode(RequestInput.self).flatMap({ requestInput in
            return User.allActiveUsers(conn: req, requestInput: requestInput).flatMap({ users in
                return self.getUserStatistics(req: req, users: users)
            })
        })
        
    }
    
    func usersBlockedList(_ req: Request) throws -> Future<[UserStatistic]> {
        return try req.content.decode(RequestInput.self).flatMap({ requestInput in
            return User.allBlockedUsers(conn: req, requestInput: requestInput).flatMap({ users in
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
        
        return User.allChatBlockedUsers(conn: req).map { users_chatBlocks  in
            
            return users_chatBlocks.reduce(into: [Int:User]()) { result, user_chatBlock in
                
                let user = user_chatBlock.0
                guard let userId = user.id else {return}
                
                if result[userId] == nil {
                    result[userId] = user
                }
                
                }
                .reduce(into: [User](), { result, each in
                    result.append(each.value) })
            }.flatMap({ users in
                return self.getUserStatistics(req: req, users: users)
            })
    }
    
    
    func userAllowAccess(_ req: Request) throws -> Future<User> {
        return try req.content.decode(UserAllowAccessInput.self).flatMap({ input in
            return User.query(on: req, withSoftDeleted: true).filter(\.id == input.userId).first().flatMap({ user in
                guard let user = user else {
                    throw Constants.errors.wrongUserId
                }
                return user.restore(on: req)
            })
        })
    }
    
    func userDenyAccess(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap({ user in
            return user.delete(on: req).flatMap({ _ in
                return try LogoutController.logoutAllDevices(req: req, user: user) 
            })
        })
    }
}

extension UserAdminController {
    
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

