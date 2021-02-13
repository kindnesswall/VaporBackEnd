//
//  ConfigurationsPath.swift
//  App
//
//  Created by Amir Hossein on 2/7/21.
//

import Foundation

struct ConfigurationsPath: AppDirectoryDetector {
    
    private static var mainDirPath: String { return "\(appDirectory)/config/main/" }
    private static var replicaDirPath: String { return "\(appDirectory)/config/replica/" }
    private static var sharedDirPath: String { return "\(appDirectory)/config/shared/" }
    
    static func path(of file: FileType) -> String {
        
        let dirPath: String
        switch file {
        case .main:
            dirPath = mainDirPath
        case .replica:
            dirPath = replicaDirPath
        case .sms,
             .apns,
             .firebase,
             .googleIdentityToolkit,
             .demoAccount,
             .applicationStoreLinks:
            dirPath = sharedDirPath
        }
        
        return "\(dirPath)\(file.name)"
    }
    
    enum FileType {
        case main
        case replica
        case sms
        case apns
        case firebase
        case googleIdentityToolkit
        case demoAccount
        case applicationStoreLinks
        
        fileprivate var name: String {
            switch self {
            case .main:
                return "config.json"
            case .replica:
                return "replica.json"
            case .sms:
                return "sms_config.json"
            case .apns:
                return "apns_config.json"
            case .firebase:
                return "firebase_config.json"
            case .googleIdentityToolkit:
                return "google_identity_toolkit_config.json"
            case .demoAccount:
                return "demo_account_credential.json"
            case .applicationStoreLinks:
                return "application_store_links.json"
            }
        }
    }
}

struct CertificatesPath: AppDirectoryDetector {
    private static let dirPath = "\(appDirectory)/certificates/"
    
    static func path(of file: FileType) -> String {
        return "\(dirPath)\(file.name)"
    }
    
    enum FileType {
        case apns
        case firebase
        
        var name: String {
            switch self {
            case .apns:
                return "aps_development.pem"
            case .firebase:
                return "firebase.json"
            }
        }
    }
    
}

struct LogsPath: AppDirectoryDetector {
    static let dirPath = "\(appDirectory)/log/"
    static let fileExtension = "txt"
}
