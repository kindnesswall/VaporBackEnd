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

class AppErrorCatch {
    public static func printError(error:Error){
        print(error.localizedDescription)
    }
}

class ErrorConstants {
    
    let tryOneMinuteLater = AppError(identifier: "tryOneMinuteLater", reason: "Please try one minute later")
    let unauthorizedRequest = AppError(identifier: "unauthorizedRequest", reason: "Request is unauthorized")
    let unauthorizedSocket = AppError(identifier: "unauthorizedSocket", reason: "Socket is unauthorized")
    let unauthorizedGift = AppError(identifier: "unauthorizedGift", reason: "Gift is unauthorized for this operation")
    let invalidPhoneNumber = AppError(identifier: "invalidPhoneNumber", reason: "The phone number is invalid")
    let invalidActivationCode = AppError(identifier: "invalidActivationCode", reason: "The activation code is invalid")
    let nilUserId = AppError(identifier: "nilUserId", reason: "User Id is nil")
    let nilGiftId = AppError(identifier: "nilGiftId", reason: "Gift Id is nil")
    
}
