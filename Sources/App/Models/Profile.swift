//
//  Profile.swift
//  App
//
//  Created by Amir Hossein on 5/27/19.
//

import Vapor

final class UserProfile : Content {
    let name: String?
    let image: String?
    
    init(name: String?,
         image: String?) {
        self.name = name
        self.image = image
    }
    
    final class Input: Content {
        let name: String?
        let image: String?
    }
}



