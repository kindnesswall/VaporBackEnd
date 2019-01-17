//
//  AppError.swift
//  App
//
//  Created by Amir Hossein on 1/16/19.
//

import Foundation
import Vapor

class AppError : Error , Debuggable {
    var identifier: String
    var reason: String
    
    init(identifier: String,reason: String) {
        self.identifier = identifier
        self.reason = reason
    }
}

class ErrorConstants {
    
    let unAuthorizedGift = AppError(identifier: "unAuthorizedGift", reason: "Gift is unAuthorized for this operation")
    let invalidPhoneNumber = AppError(identifier: "invalidPhoneNumber", reason: "The phone number is invalid")
    let invalidUserId = AppError(identifier: "invalidUserId", reason: "User Id is invalid")
    
}
