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
    
    final class Login : Content {
        var phoneNumber:String
        var activationCode:String?
    }
    
    final class FirebaseLogin: Content {
        var idToken: String
        
        init(idToken: String) {
            self.idToken = idToken
        }
    }
    
    final class ChangePhoneNumber: Content {
        var toPhoneNumber:String
        var activationCode_from:String?
        var activationCode_to:String?
    }
    
    final class Country: Content {
        var countryId: Int
    }
    
    final class UserPushNotification : Content {
        var type: String
        var devicePushToken: String
    }
    
    struct ApplicationVersion: Content {
        var availableVersionName: String
        var availableVersionCode: Int
        var requiredVersionName: String
        var requiredVersionCode: Int
        var downloadLink: String?
    }
    
    struct TextMessage : Content {
        var chatId:Int
        var text:String
        var type: String?
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
