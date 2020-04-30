//
//  PhoneNumberValidator.swift
//  App
//
//  Created by Amir Hossein on 4/30/20.
//

import Foundation

protocol PhoneNumberValidator {
    func validate(phoneNumber: String) throws -> String
}

extension PhoneNumberValidator {
    func validate(phoneNumber inputPhoneNumber: String) throws -> String {
        
        //  TO DO: code and phone number can be divided in input, by "," or by separate parameters
        //  first example: {phoneNumber: "+code,number"}
        //  second example: {code: code, phoneNumber: number}
        
        var phoneNumber = inputPhoneNumber
        phoneNumber.dropPlus()
        
        guard phoneNumber.isCorrectPhoneNumber(),
            let englishPhoneNumber = phoneNumber.castNumberToEnglish()
            else {
                throw Constants.errors.invalidPhoneNumber
        }
        
        return "+\(englishPhoneNumber)"
    }
}
