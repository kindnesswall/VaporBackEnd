
//
//  Inputs.swift
//  App
//
//  Created by Amir Hossein on 10/8/19.
//

import Vapor

class Inputs {
    
    final class RejectReason: Content {
        var rejectReason: String
    }
    
    struct Login: Content {
        let phoneNumber: String
        let activationCode: String?
        let pushNotification: UserPushNotification?
    }
    
    struct FirebaseLogin: Content {
        let idToken: String
        let pushNotification: UserPushNotification?
    }
    
    struct FirebaseRequest: Codable {
        let idToken: String
    }
    
    final class ChangePhoneNumber: Content {
        var toPhoneNumber:String
        var activationCode_from:String?
        var activationCode_to:String?
    }
    
    final class Country: Content {
        var countryId: Int
    }
    
    struct UserPushNotification : Content {
        let type: PushNotificationType
        let devicePushToken: String
    }
    
    struct ApplicationVersion: Content {
        var availableVersionName: String
        var availableVersionCode: Int
        var requiredVersionName: String
        var requiredVersionCode: Int
        var downloadLink: String?
    }
    
    struct UserQuery: Content {
        var beforeId:Int?
        var count:Int?
        var phoneNumber:String?
    }
    
    struct SMS: Codable {
        var originator: String
        var pattern_code: String
        var recipient: String
        var values: [String:String]
    }
    
    struct GiftRequestStatus: Codable {
        enum Status: String, Codable {
            case wasReceived
            case wasCenceled
            case didNotResponse
        }
        
        let status: Status
        let statusDescription: String?
    }
}
