//
//  DemoAccountPhoneNumber.swift
//  App
//
//  Created by Amir Hossein on 7/18/20.
//

import Foundation

struct DemoAccountPhoneNumber {
    
    private let codes: [String]
    private let phoneNumber: String
    
    init(codes: [String], phoneNumber: String) {
        self.codes = codes
        self.phoneNumber = phoneNumber
    }
    
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
