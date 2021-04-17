//
//  Constants.swift
//  COpenSSL
//
//  Created by Amir Hossein on 1/5/19.
//

import Foundation

class Constants {
    
    static let maxFetchCount = 50
    
}

extension Constants {
    static func maxFetchCount(bound: Int?) -> Int {
        return min(bound ?? maxFetchCount, maxFetchCount)
    }
}
