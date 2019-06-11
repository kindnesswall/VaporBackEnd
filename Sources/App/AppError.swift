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
    let unreviewedGift = AppError(identifier: "unreviewedGift", reason: "Gift is not reviewed")
    let unrequestedGift = AppError(identifier: "unrequestedGift", reason: "Gift is not requested")
    let giftIsAlreadyDonated = AppError(identifier: "giftIsAlreadyDonated", reason: "Gift has already been donated")
    let unauthorizedMessage = AppError(identifier: "unauthorizedMessage", reason: "Message is unauthorized for this operation")
    let invalidPhoneNumber = AppError(identifier: "invalidPhoneNumber", reason: "The phone number is invalid")
    let invalidActivationCode = AppError(identifier: "invalidActivationCode", reason: "The activation code is invalid")
    let nilUserId = AppError(identifier: "nilUserId", reason: "User id is nil")
    let wrongUserId = AppError(identifier: "wrongUserId", reason: "User id is wrong")
    let nilGiftId = AppError(identifier: "nilGiftId", reason: "Gift id is nil")
    let nilGiftUserId = AppError(identifier: "nilGiftUserId", reason: "Gift user id is nil")
    let messageNotFound = AppError(identifier: "messageNotFound", reason: "Message not found")
    let giftNotFound = AppError(identifier: "giftNotFound", reason: "Gift not found")
    let userAccessIsDenied = AppError(identifier: "userAccessIsDenied", reason: "User access is denied")
    let chatNotFound = AppError(identifier: "chatNotFound", reason: "Chat not found")
    let nilChatId = AppError(identifier: "nilChatId", reason: "Chat id is nil")
    let contactNotFound = AppError(identifier: "contactNotFound", reason: "Contact not found")
    let chatNotificationNotFound = AppError(identifier: "chatNotificationNotFound", reason: "Chat's Notification not found")
    let redundentAck = AppError(identifier: "redundentAck", reason: "Ack is redundent")
}
