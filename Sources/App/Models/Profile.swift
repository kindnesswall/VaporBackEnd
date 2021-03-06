//
//  Profile.swift
//  App
//
//  Created by Amir Hossein on 5/27/19.
//

import Vapor

final class UserProfile : Content {
    var id: Int
    var name:String?
    var image:String?
    var phoneNumber:String?
    var isCharity:Bool
    var charityName:String?
    var charityImage:String?
    var isSupporter:Bool
    let isAdmin: Bool?
    
    init(id:Int,
         name:String?,
         image:String?,
         phoneNumber:String?,
         isCharity:Bool,
         charityName:String?,
         charityImage:String?,
         isSupporter:Bool,
         isAdmin: Bool?) {
        
        self.id=id
        self.name=name
        self.image=image
        self.phoneNumber=phoneNumber
        self.isCharity = isCharity
        self.charityName = charityName
        self.charityImage = charityImage
        self.isSupporter = isSupporter
        self.isAdmin = isAdmin
    }
    
    final class Input: Content {
        var name:String?
        var image:String?
    }
}



