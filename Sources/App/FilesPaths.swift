//
//  FilesPaths.swift
//  App
//
//  Created by Amir Hossein on 2/7/21.
//

import Foundation

struct ConfigurationsPaths {
    
    private static let secretsDirPath = "/run/secrets/"
    
    static func path(of file: FileType) -> String {
        return "\(secretsDirPath)\(file.name)"
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
                return "main_config.json"
            case .replica:
                return "replica_config.json"
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

struct CertificatesPaths: AppDirectoryDetector {
    
    private static let secretsDirPath = "/run/secrets/"
    
    static func path(of file: FileType) -> String {
        return "\(secretsDirPath)\(file.name)"
    }
    
    enum FileType {
//        case apns(APNSFileType)
        case firebase
        
        var name: String {
            switch self {
            case .firebase:
                return "firebase_certificate.json"
            }
        }
    }
    
//    enum APNSFileType {
//    }
    
}

struct LogsPath: AppDirectoryDetector {
    static let dirPath = "\(appDirectory)/log/"
    static let fileExtension = "txt"
}
