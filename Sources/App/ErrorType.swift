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
    case unauthorizedGift
    case unreviewedGift
    case unrequestedGift
    case giftCannotBeDonatedToTheOwner
    case giftIsAlreadyDonated
    case deletedGift
    case donatedGiftUnaccepted
    case alreadyExists
    case charityInfoAlreadyExists
    case firebaseAuthenticationError
    case invalidPhoneNumber
    case phoneNumberHasExisted
    case invalidActivationCode
    case expiredActivationCode
    case pushPayloadIsNotValid
    case invalidType
    case invalid
    case nilUserId
    case nilTokenId
    case nilGiftId
    case nilGiftUserId
    case nilCountryId
    case notFound
    case notFoundOrHasExpired
    case userNotFound
    case giftNotFound
    case profileNotFound
    case charityInfoNotFound
    case activationCodeNotFound
    case countryNotFound
    case provinceNotFound
    case cityNotFound
    case userAccessIsDenied
    case userIsNotCharity
    case serverThrowsException
    case objectEncodingFailed
    case transactionFailed
    case failedToSendSMS
    case failedToSendAPNSPush
    case failedToSendFirebasePush
    case failedToLoginWithFirebase
    case phoneNumberIsNotAccessible
    case giftHasRequest
    case notAcceptable
}

extension ErrorType {
    var status: HTTPResponseStatus {
        switch self {
        case .tryOneMinuteLater:
            return .tooManyRequests
        case .unauthorizedRequest,
             .unauthorizedGift:
            return .methodNotAllowed
        case .notAcceptable,
             .unreviewedGift,
             .unrequestedGift,
             .giftCannotBeDonatedToTheOwner,
             .giftIsAlreadyDonated,
             .deletedGift,
             .donatedGiftUnaccepted,
             .alreadyExists,
             .charityInfoAlreadyExists,
             .firebaseAuthenticationError,
             .invalidPhoneNumber,
             .phoneNumberHasExisted,
             .invalidActivationCode,
             .expiredActivationCode,
             .pushPayloadIsNotValid,
             .invalidType,
             .invalid,
             .phoneNumberIsNotAccessible,
             .giftHasRequest:
            return .notAcceptable
        case .nilUserId,
             .nilTokenId,
             .nilGiftId,
             .nilGiftUserId,
             .nilCountryId,
             .notFound,
             .notFoundOrHasExpired,
             .userNotFound,
             .giftNotFound,
             .profileNotFound,
             .charityInfoNotFound,
             .activationCodeNotFound,
             .countryNotFound,
             .provinceNotFound,
             .cityNotFound:
            return .notFound
        case .userAccessIsDenied:
            return .forbidden
        case .userIsNotCharity:
            return .badRequest
        case .serverThrowsException,
             .objectEncodingFailed,
             .transactionFailed,
             .failedToSendSMS,
             .failedToSendAPNSPush,
             .failedToSendFirebasePush,
             .failedToLoginWithFirebase:
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
        case .unauthorizedGift:
            return "Gift is unauthorized for this operation"
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
        case .alreadyExists:
            return "Item already exists"
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
        case .expiredActivationCode:
            return "The activation code has been expired"
        case .pushPayloadIsNotValid:
            return "Push payload is not valid"
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
        case .nilCountryId:
            return "Country id is nil"
        case .notFound:
            return "The item has not been found"
        case .notFoundOrHasExpired:
            return "The item has not been found or has expired"
        case .userNotFound:
            return "User not found"
        case .giftNotFound:
            return "Gift not found"
        case .profileNotFound:
            return "Profile not found"
        case .charityInfoNotFound:
            return "Charity information not found"
        case .activationCodeNotFound:
            return "Activation code not found"
        case .countryNotFound:
            return "Country not found"
        case .provinceNotFound:
            return "Province not found"
        case .cityNotFound:
            return "City not found"
        case .userAccessIsDenied:
            return "User access is denied"
        case .userIsNotCharity:
            return "User is not charity"
        case .serverThrowsException:
            return "Server throws exception"
        case .objectEncodingFailed:
            return "Object encoding failed"
        case .transactionFailed:
            return "Transaction failed, please try again"
        case .failedToSendSMS:
            return "Failed to send SMS"
        case .failedToSendAPNSPush:
            return "Failed to send APNS push"
        case .failedToSendFirebasePush:
            return "Failed to send Firebase push"
        case .failedToLoginWithFirebase:
            return "Failed to login with Firebase"
        case .phoneNumberIsNotAccessible:
            return "The phone number is not accessible"
        case .giftHasRequest:
            return "Gift has request"
        case .notAcceptable:
            return "Not acceptable"
        }
    }
}

extension ErrorType {
    var identifier: String {
        return self.rawValue
    }
}

