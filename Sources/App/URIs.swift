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
    
    var gifts_register : String {
        return "\(apiRoute)/gifts/register"
    }
    
    var gifts_owner : String {
        return "\(apiRoute)/gifts/owner"
    }
    var gifts_images : String {
        return "\(apiRoute)/gifts/images"
    }
    
    var gifts_accept : String {
        return "\(apiRoute)/gifts/accept"
    }
    var gifts_reject : String {
        return "\(apiRoute)/gifts/reject"
    }
    var gifts_review : String {
        return "\(apiRoute)/gifts/review"
    }
}
