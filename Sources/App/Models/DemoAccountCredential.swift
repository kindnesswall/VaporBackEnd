//
//  DemoAccountCredential.swift
//  App
//
//  Created by Amir Hossein on 7/18/20.
//

import Foundation

struct DemoAccountCredential: Codable {
    
    private let codes: [String]
    private let phoneNumber: String
    
    let activationCode: String
    
    var phoneNumbers: [String] {
        return codes.map { "\($0)\(phoneNumber)" }
    }
    
    func validate(phoneNumber: String) -> Bool {
        for each in self.phoneNumbers {
            if phoneNumber == each { return true }
        }
        return false
    }
}
