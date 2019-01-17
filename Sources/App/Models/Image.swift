//
//  Image.swift
//  App
//
//  Created by Amir Hossein on 1/17/19.
//

import Vapor

final class ImageInput: Content {
    var image:Data
    var imageName : String
}

final class ImageOutput: Content {
    var address:String
    
    init(address:String) {
        self.address=address
    }
}
