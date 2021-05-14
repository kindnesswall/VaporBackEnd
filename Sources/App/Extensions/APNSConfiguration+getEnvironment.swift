//
//  APNSConfiguration+getEnvironment.swift
//  
//
//  Created by Amir Hossein on 6/29/21.
//

import Foundation
import APNS

extension APNSConfiguration {
    func getEnvironment() -> APNSwiftConfiguration.Environment? {
        switch environment {
        case "production":
            return .production
        case "sandbox":
            return .sandbox
        default:
            return nil
        }
    }
}
