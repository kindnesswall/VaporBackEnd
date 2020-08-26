//
//  AppError.swift
//  App
//
//  Created by Amir Hossein on 1/16/19.
//

import Foundation
import Vapor


extension Abort {
    init(_ type: ErrorType) {
        self.init(type.status, reason: type.reason, identifier: type.identifier)
    }
}


enum ErrorType: String {
    case tryOneMinuteLater
    case unauthorizedRequest
    case unauthorizedSocket
    case unauthorizedGift
    case unauthorizedMessage
    case unreviewedGift
    case unrequestedGift
    case giftCannotBeDonatedToTheOwner
    case giftIsAlreadyDonated
    case deletedGift
    case donatedGiftUnaccepted
    case charityInfoAlreadyExists
    case firebaseAuthenticationError
    case invalidPhoneNumber
    case phoneNumberHasExisted
    case invalidActivationCode
    case pushPayloadIsNotValid
    case wrongPushNotificationType
    case chatHasBlockedByUser
    case invalidType
    case invalid
    case nilUserId
    case nilTokenId
    case nilGiftId
    case nilGiftUserId
    case messageNotFound
    case nilMessageId
    case nilCountryId
    case notFound
    case userNotFound
    case giftNotFound
    case chatNotFound
    case nilChatId
    case profileNotFound
    case chatNotificationNotFound
    case charityInfoNotFound
    case activationCodeNotFound
    case countryNotFound
    case userAccessIsDenied
    case chatHasBlocked
    case redundentAck
    case userWasAlreadyBlocked
    case userWasAlreadyUnblocked
    case userIsNotCharity
    case chatIsNotAllowed
    case serverThrowsException
    case objectEncodingFailed
}

extension ErrorType {
    var status: HTTPResponseStatus {
        switch self {
        case .tryOneMinuteLater:
            return .tooManyRequests
        case .unauthorizedRequest,
             .unauthorizedSocket,
             .unauthorizedGift,
             .unauthorizedMessage,
             .chatIsNotAllowed:
            return .methodNotAllowed
        case .unreviewedGift,
             .unrequestedGift,
             .giftCannotBeDonatedToTheOwner,
             .giftIsAlreadyDonated,
             .deletedGift,
             .donatedGiftUnaccepted,
             .charityInfoAlreadyExists,
             .firebaseAuthenticationError,
             .invalidPhoneNumber,
             .phoneNumberHasExisted,
             .invalidActivationCode,
             .pushPayloadIsNotValid,
             .wrongPushNotificationType,
             .chatHasBlockedByUser,
             .invalidType,
             .invalid:
            return .notAcceptable
        case .nilUserId,
             .nilTokenId,
             .nilGiftId,
             .nilGiftUserId,
             .messageNotFound,
             .nilMessageId,
             .nilCountryId,
             .notFound,
             .userNotFound,
             .giftNotFound,
             .chatNotFound,
             .nilChatId,
             .profileNotFound,
             .chatNotificationNotFound,
             .charityInfoNotFound,
             .activationCodeNotFound,
             .countryNotFound:
            return .notFound
        case .userAccessIsDenied,
             .chatHasBlocked:
            return .forbidden
        case .redundentAck,
             .userWasAlreadyBlocked,
             .userWasAlreadyUnblocked:
            return .alreadyReported
        case .userIsNotCharity:
            return .badRequest
        case .serverThrowsException,
             .objectEncodingFailed:
            return .internalServerError
        
        }
    }
}

extension ErrorType {
    var reason: String {
        switch self {
        case .tryOneMinuteLater:
            return "Please try one minute later"
        case .unauthorizedRequest:
            return "Request is unauthorized"
        case .unauthorizedSocket:
            return "Socket is unauthorized"
        case .unauthorizedGift:
            return "Gift is unauthorized for this operation"
        case .unauthorizedMessage:
            return "Message is unauthorized for this operation"
        case .unreviewedGift:
            return "Gift is not reviewed"
        case .unrequestedGift:
            return "Gift is not requested"
        case .giftCannotBeDonatedToTheOwner:
            return "Gift can not be donated to the owner"
        case .giftIsAlreadyDonated:
            return "Gift has already been donated"
        case .deletedGift:
            return "Gift has been deleted"
        case .donatedGiftUnaccepted:
            return "Unacceptable operation for a donated gift"
        case .charityInfoAlreadyExists:
            return "Charity information already exists"
        case .firebaseAuthenticationError:
            return "Firebase authentication error"
        case .invalidPhoneNumber:
            return "The phone number is invalid"
        case .phoneNumberHasExisted:
            return "Phone number has existed"
        case .invalidActivationCode:
            return "The activation code is invalid"
        case .pushPayloadIsNotValid:
            return "Push payload is not valid"
        case .wrongPushNotificationType:
            return "Push Notification Type is wrong"
        case .chatHasBlockedByUser:
            return "Chat has blocked by user"
        case .invalidType:
            return "The input type is invalid"
        case .invalid:
            return "The input is invalid"
        case .nilUserId:
            return "User id is nil"
        case .nilTokenId:
            return "Token id is nil"
        case .nilGiftId:
            return "Gift id is nil"
        case .nilGiftUserId:
            return "Gift user id is nil"
        case .messageNotFound:
            return "Message not found"
        case .nilMessageId:
            return "Message id is nil"
        case .nilCountryId:
            return "Country id is nil"
        case .notFound:
            return "The item has not been found"
        case .userNotFound:
            return "User not found"
        case .giftNotFound:
            return "Gift not found"
        case .chatNotFound:
            return "Chat not found"
        case .nilChatId:
            return "Chat id is nil"
        case .profileNotFound:
            return "Profile not found"
        case .chatNotificationNotFound:
            return "Chat's Notification not found"
        case .charityInfoNotFound:
            return "Charity information not found"
        case .activationCodeNotFound:
            return "Activation code not found"
        case .countryNotFound:
            return "Country not found"
        case .userAccessIsDenied:
            return "User access is denied"
        case .chatHasBlocked:
            return "Chat has blocked"
        case .redundentAck:
            return "Ack is redundent"
        case .userWasAlreadyBlocked:
            return "User was already blocked"
        case .userWasAlreadyUnblocked:
            return "User was already unblocked"
        case .userIsNotCharity:
            return "User is not charity"
        case .chatIsNotAllowed:
            return "Chat is not allowed"
        case .serverThrowsException:
            return "Server throws exception"
        case .objectEncodingFailed:
            return "Object encoding failed"
        
        }
    }
}

extension ErrorType {
    var identifier: String {
        return self.rawValue
    }
}

