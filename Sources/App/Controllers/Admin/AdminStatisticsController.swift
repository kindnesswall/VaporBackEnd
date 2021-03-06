//
//  AdminStatisticsController.swift
//  App
//
//  Created by Amir Hossein on 8/1/19.
//

import Vapor
import FluentPostgreSQL

final class AdminStatisticsController {
    
    func getStatistics(_ req: Request) throws -> Future<Statistics> {
        
        let registeredGifts = Gift.query(on: req).count()
        let donatedGifts = Gift.query(on: req).filter(\.donatedToUserId != nil).count()
        let unreviewedGifts = Gift.query(on: req).filter(\.isReviewed == false).count()
        let rejectedGifts = Gift.query(on: req, withSoftDeleted: true).filter(\.isRejected == true).count()
        let deletedGifts = Gift.query(on: req, withSoftDeleted: true).filter(\.isDeleted == true).count()
        
        let activeUsers = User.query(on: req).count()
        let blockedUsers = User.query(on: req, withSoftDeleted: true).filter(\.deletedAt != nil).count()
        let chatBlockedUsers = ChatBlock.query(on: req).all().map { chatBlocks -> Int in
            return chatBlocks.reduce(into: [Int:Int](), { (result, chatBlock) in
                result[chatBlock.blockedUserId, default: 0] += 1
            }).count
        }
        
        return getStatistics(registeredGifts: registeredGifts,
                             donatedGifts: donatedGifts,
                             unreviewedGifts: unreviewedGifts,
                             rejectedGifts: rejectedGifts,
                             deletedGifts: deletedGifts,
                             activeUsers: activeUsers,
                             blockedUsers: blockedUsers,
                             chatBlockedUsers: chatBlockedUsers)
    }
    
    
    func getStatistics(registeredGifts:Future<Int>,
                       donatedGifts:Future<Int>,
                       unreviewedGifts:Future<Int>,
                       rejectedGifts:Future<Int>,
                       deletedGifts:Future<Int>,
                       activeUsers:Future<Int>,
                       blockedUsers:Future<Int>,
                       chatBlockedUsers:Future<Int>)->Future<Statistics>{
        
        return registeredGifts.flatMap { registeredGifts in
        return donatedGifts.flatMap { donatedGifts in
        return unreviewedGifts.flatMap { unreviewedGifts in
        return rejectedGifts.flatMap { rejectedGifts in
        return deletedGifts.flatMap { deletedGifts in
        return activeUsers.flatMap { activeUsers in
        return blockedUsers.flatMap { blockedUsers in
        return chatBlockedUsers.map { chatBlockedUsers in
            let statistics = Statistics()
            statistics.registeredGifts = registeredGifts
            statistics.donatedGifts = donatedGifts
            statistics.unreviewedGifts = unreviewedGifts
            statistics.rejectedGifts = rejectedGifts
            statistics.deletedGifts = deletedGifts
            statistics.activeUsers = activeUsers
            statistics.blockedUsers = blockedUsers
            statistics.chatBlockedUsers = chatBlockedUsers
            return statistics }}}}}}}
        }
    }
    
    
}
