//
//  AdminStatisticsController.swift
//  App
//
//  Created by Amir Hossein on 8/1/19.
//

import Vapor
import Fluent
import FluentPostgresDriver

final class AdminStatisticsController {
    
    func getStatistics(_ req: Request) throws -> EventLoopFuture<Statistics> {
        let db = req.db
        
        let registeredGifts = Gift.query(on: db).count()
        let donatedGifts = Gift.query(on: db)
            .filter(\.$donatedToUser.$id != nil)
            .count()
        let unreviewedGifts = Gift.query(on: db)
            .filter(\.$isReviewed == false)
            .count()
        let rejectedGifts = Gift.query(on: db)
            .withDeleted()
            .filter(\.$isRejected == true)
            .count()
        let deletedGifts = Gift.query(on: db)
            .withDeleted()
            .filter(\.$isDeleted == true)
            .count()
        
        let activeUsers = User.query(on: db).count()
        let blockedUsers = User.query(on: db)
            .withDeleted()
            .filter(\.$deletedAt != nil)
            .count()
        
        return getStatistics(registeredGifts: registeredGifts,
                             donatedGifts: donatedGifts,
                             unreviewedGifts: unreviewedGifts,
                             rejectedGifts: rejectedGifts,
                             deletedGifts: deletedGifts,
                             activeUsers: activeUsers,
                             blockedUsers: blockedUsers)
    }
    
    
    func getStatistics(registeredGifts:EventLoopFuture<Int>,
                       donatedGifts:EventLoopFuture<Int>,
                       unreviewedGifts:EventLoopFuture<Int>,
                       rejectedGifts:EventLoopFuture<Int>,
                       deletedGifts:EventLoopFuture<Int>,
                       activeUsers:EventLoopFuture<Int>,
                       blockedUsers:EventLoopFuture<Int>)
    -> EventLoopFuture<Statistics> {
        
        return registeredGifts.flatMap { registeredGifts in
        return donatedGifts.flatMap { donatedGifts in
        return unreviewedGifts.flatMap { unreviewedGifts in
        return rejectedGifts.flatMap { rejectedGifts in
        return deletedGifts.flatMap { deletedGifts in
        return activeUsers.flatMap { activeUsers in
        return blockedUsers.map { blockedUsers in
            let statistics = Statistics()
            statistics.registeredGifts = registeredGifts
            statistics.donatedGifts = donatedGifts
            statistics.unreviewedGifts = unreviewedGifts
            statistics.rejectedGifts = rejectedGifts
            statistics.deletedGifts = deletedGifts
            statistics.activeUsers = activeUsers
            statistics.blockedUsers = blockedUsers
            return statistics }}}}}}}
    }
    
    
}
