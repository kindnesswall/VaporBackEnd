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
    
    final class ChangePhoneNumber: Content {
        var toPhoneNumber:String
        var activationCode:String?
    }
    
}