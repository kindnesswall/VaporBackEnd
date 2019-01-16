//
//  AppErrors.swift
//  App
//
//  Created by Amir Hossein on 1/16/19.
//

import Foundation
import Vapor

class AppErrors {
    
    class AppErrorsType : Error , Debuggable {
        var identifier: String
        var reason: String
        
        init(identifier: String,reason: String) {
            self.identifier = identifier
            self.reason = reason
        }
    }
    
    static let unAuthorizedGift = AppErrorsType(identifier: "unAuthorizedGift", reason: "Gift is unAuthorized for this operation")

    
}
