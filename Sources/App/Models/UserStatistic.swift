//
//  UserStatistic.swift
//  App
//
//  Created by Amir Hossein on 9/20/19.
//

import Vapor

final class UserStatistic : Content{
    
    var user:User
    var registeredGifts:Int?
    var rejectedGifts:Int?
    var donatedGifts:Int?
    var receivedGifts:Int?
    var blockedChats:Int?
    
    init(user:User) {
        self.user = user
    }
    
} 
