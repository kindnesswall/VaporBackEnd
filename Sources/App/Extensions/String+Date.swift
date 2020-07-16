//
//  String + Date.swift
//  App
//
//  Created by Amir Hossein on 1/17/19.
//

import Foundation

extension String {
    static func getCurrentDate(withClock: Bool)->String{
        let currentDate = Date().description.components(separatedBy: " ")
        var description = ""
        for i in 0..<currentDate.count {
            description += currentDate[i]
            if !withClock { break }
            if i > 0 { break }
            description += "-"
        }
        return description
    }
}
