//
//  String + Date.swift
//  App
//
//  Created by Amir Hossein on 1/17/19.
//

import Foundation

extension String {
    static func getCurrentDate()->String{
        let currentDateComponents = Date().description.components(separatedBy: " ")
        var description = ""
        for i in 0..<currentDateComponents.count-1 {
            description += currentDateComponents[i]
        }
        return description
    }
}
