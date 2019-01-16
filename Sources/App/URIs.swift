//
//  URIs.swift
//  COpenSSL
//
//  Created by Amir Hossein on 1/6/19.
//

import Foundation

class URIs {
    private let apiRoute:String
    init(apiRoute:String) {
        self.apiRoute=apiRoute
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
    
    var gifts_categories : String {
        return "\(gifts)/\(categories)"
    }
}
