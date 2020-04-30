//
//  String + PhoneNumber.swift
//  App
//
//  Created by Amir Hossein on 1/16/19.
//

import Foundation

extension String {
    public func isCorrectPhoneNumber()->Bool{
        guard let number = self.castNumberToEnglish() else {
            return false
        }
        guard number.count >= 10 else {
            return false
        }
        return true
    }
    mutating func dropPlus() {
        if let plusIndex = firstIndex(of: "+") {
            remove(at: plusIndex)
        }
    }
}
