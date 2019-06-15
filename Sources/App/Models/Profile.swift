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
    
    init(id:Int,name:String?,image:String?) {
        self.id=id
        self.name=name
        self.image=image
    }
    
    final class Input: Content {
        var name:String?
        var image:String?
    }
}



