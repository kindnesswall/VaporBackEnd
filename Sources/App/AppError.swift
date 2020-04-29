//
//  AppError.swift
//  App
//
//  Created by Amir Hossein on 1/16/19.
//

import Foundation
import Vapor

class AppErrorCatch {
    public static func printError(error:Error){
        print(error)
    }
}

class ErrorConstants {
    
    //MARK: tooManyRequests
    let tryOneMinuteLater = Abort(.tooManyRequests, reason: "Please try one minute later", identifier: "tryOneMinuteLater")
    
    //MARK: methodNotAllowed
    let unauthorizedRequest = Abort(.methodNotAllowed, reason: "Request is unauthorized",identifier: "unauthorizedRequest")
    let unauthorizedSocket = Abort(.methodNotAllowed, reason: "Socket is unauthorized",identifier: "unauthorizedSocket")
    let unauthorizedGift = Abort(.methodNotAllowed, reason: "Gift is unauthorized for this operation",identifier: "unauthorizedGift")
    let unauthorizedMessage = Abort(.methodNotAllowed, reason: "Message is unauthorized for this operation",identifier: "unauthorizedMessage")
    
    //MARK: notAcceptable
    let unreviewedGift = Abort(.notAcceptable, reason: "Gift is not reviewed",identifier: "unreviewedGift")
    let unrequestedGift = Abort(.notAcceptable, reason: "Gift is not requested",identifier: "unrequestedGift")
    let giftCannotBeDonatedToTheOwner = Abort(.notAcceptable, reason: "Gift can not be donated to the owner", identifier: "giftCannotBeDonatedToTheOwner")
    let giftIsAlreadyDonated = Abort(.notAcceptable, reason: "Gift has already been donated",identifier: "giftIsAlreadyDonated")
    let charityInfoAlreadyExists = Abort(.notAcceptable ,reason: "Charity information already exists",identifier: "charityInfoAlreadyExists")
    let firebaseAuthenticationError = Abort(.notAcceptable, reason: "Firebase authentication error", identifier: "firebaseAuthenticationError")
    
    //MARK: nonAuthoritativeInformation
    let invalidPhoneNumber = Abort(.nonAuthoritativeInformation, reason: "The phone number is invalid",identifier: "invalidPhoneNumber")
    let phoneNumberHasExisted = Abort(.nonAuthoritativeInformation, reason: "Phone number has existed",identifier: "phoneNumberHasExisted")
    let invalidActivationCode = Abort(.nonAuthoritativeInformation, reason: "The activation code is invalid",identifier: "invalidActivationCode")
    let wrongUserId = Abort(.nonAuthoritativeInformation, reason: "User id is wrong",identifier: "wrongUserId")
    let pushPayloadIsNotValid = Abort(.nonAuthoritativeInformation ,reason: "Push payload is not valid",identifier: "pushPayloadIsNotValid")
    let wrongPushNotificationType = Abort(.nonAuthoritativeInformation, reason: "Push Notification Type is wrong",identifier: "wrongPushNotificationType")
    
    //MARK: notFound
    let nilUserId = Abort(.notFound, reason: "User id is nil",identifier: "nilUserId")
    let nilTokenId = Abort(.notFound, reason: "Token id is nil",identifier: "nilTokenId")
    let nilGiftId = Abort(.notFound, reason: "Gift id is nil",identifier: "nilGiftId")
    let nilGiftUserId = Abort(.notFound, reason: "Gift user id is nil",identifier: "nilGiftUserId")
    let messageNotFound = Abort(.notFound, reason: "Message not found",identifier: "messageNotFound")
    let nilMessageId = Abort(.notFound, reason: "Message id is nil",identifier: "nilMessageId")
    let nilCountryId = Abort(.notFound, reason: "Country id is nil", identifier: "nilCountryId")
    let giftNotFound = Abort(.notFound, reason: "Gift not found",identifier: "giftNotFound")
    let chatNotFound = Abort(.notFound, reason: "Chat not found",identifier: "chatNotFound")
    let nilChatId = Abort(.notFound, reason: "Chat id is nil",identifier: "nilChatId")
    let contactNotFound = Abort(.notFound, reason: "Contact not found",identifier: "contactNotFound")
    let chatNotificationNotFound = Abort(.notFound, reason: "Chat's Notification not found",identifier: "chatNotificationNotFound")
    let charityInfoNotFound = Abort(.notFound, reason: "Charity information not found",identifier: "charityInfoNotFound")
    let activationCodeNotFound = Abort(.notFound, reason: "Activation code not found", identifier: "activationCodeNotFound")
    let countryNotFound = Abort(.notFound, reason: "Country not found", identifier: "countryNotFound")
    
    //MARK: forbidden
    let userAccessIsDenied = Abort(.forbidden, reason: "User access is denied",identifier: "userAccessIsDenied")
    let chatHasBlocked = Abort(.forbidden, reason: "Chat has blocked",identifier: "chatHasBlocked")
    let chatHasBlockedByUser = Abort(.forbidden, reason: "Chat has blocked by user",identifier: "chatHasBlockedByUser")
    
    //MARK: alreadyReported
    let redundentAck = Abort(.alreadyReported, reason: "Ack is redundent",identifier: "redundentAck")
    let userWasAlreadyBlocked = Abort(.alreadyReported, reason: "User was already blocked",identifier: "userWasAlreadyBlocked")
    let userWasAlreadyUnblocked = Abort(.alreadyReported ,reason: "User was already unblocked",identifier: "userWasAlreadyUnblocked")
    
    //MARK: badRequest
    let userIsNotCharity = Abort(.badRequest, reason: "User is not charity",identifier: "userIsNotCharity") 
    
    //MARK: internalServerError
    let serverThrowsException = Abort(.internalServerError, reason: "Server throws exception", identifier: "serverThrowsException")
    let objectEncodingFailed = Abort(.internalServerError, reason: "Object encoding failed", identifier: "objectEncodingFailed")
}

