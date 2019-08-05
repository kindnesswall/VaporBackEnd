//
//  Statistics.swift
//  App
//
//  Created by Amir Hossein on 8/1/19.
//

import Vapor

final class Statistics: Content {
    var registeredGifts: Int?
    var donatedGifts: Int?
    var unreviewedGifts: Int?
    var rejectedGifts: Int?
    var deletedGifts: Int?
    var activeUsers: Int?
    var blockedUsers: Int?
    var chatBlockedUsers: Int?
    
}
