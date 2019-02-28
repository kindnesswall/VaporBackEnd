//
//  AppRandom.swift
//  App
//
//  Created by Amir Hossein on 2/26/19.
//

import Foundation

class AppRandom {
    
    static func randomNumber(upper_bound:Int) -> Int
    {
        return Int.random(in: 0..<upper_bound)
    }
    
    static func randomElementFromList<T>(list:[T])->T {
        let randomIndex = randomNumber(upper_bound: list.count)
        return list[randomIndex]
    }
    
    
    static func randomNumericCharacter(excludingZero:Bool = false)->String{
        
        let numbersList : [String] = {
            let nonZeroNumbers = ["1","2","3","4","5","6","7","8","9"]
            let numbers = ["0"] + nonZeroNumbers
            
            if excludingZero {
                return nonZeroNumbers
            } else {
                return numbers
            }
        }()
        
        return randomElementFromList(list: numbersList)
    }
    
    static func randomNumericString(count:Int)->String {
        var numericString = ""
        for i in 0..<count {
            var excludingZero = false
            if i==0 {
                excludingZero = true
            }
            numericString+=randomNumericCharacter(excludingZero: excludingZero)
        }
        return numericString
    }
}
