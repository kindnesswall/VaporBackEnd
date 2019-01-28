//
//  URIs.swift
//  COpenSSL
//
//  Created by Amir Hossein on 1/6/19.
//

import Foundation

class URIs {
    private let apiRoute:String
    init() {
        self.apiRoute=Constants.apiRoute
    }
    
    var gifts : String {
        return "\(apiRoute)/gifts"
    }
    var categories : String {
        return "\(apiRoute)/categories"
    }
    var register : String {
        return "\(apiRoute)/register"
    }
    var login : String {
        return "\(apiRoute)/login"
    }
    var chat : String {
        return "\(apiRoute)/chat"
    }
    
    var gifts_categories : String {
        return "\(apiRoute)/gifts/categories"
    }
    var gifts_owner : String {
        return "\(apiRoute)/gifts/owner"
    }
    var gifts_images : String {
        return "\(apiRoute)/gifts/images"
    }
}
