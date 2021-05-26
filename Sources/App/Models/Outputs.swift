//
//  Outputs.swift
//  App
//
//  Created by Amir Hossein on 9/4/20.
//

import Vapor

class Outputs {

    struct Rating: Content {
        var userRate: Int?
        var averageRate: Double?
        var votersCount: Int
        
        init(userRate: Int?, averageRate: Double?, votersCount: Int) {
            self.userRate = userRate
            self.averageRate = averageRate
            self.votersCount = votersCount
        }
    }
    
    struct UserPhoneNumber: Content {
        var phoneNumber: String
    }

}
