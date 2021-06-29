//
//  Configuration.swift
//  App
//
//  Created by Amir Hossein on 3/7/20.
//

import Foundation

class Configuration {
    var main: MainConfiguration!
    var replica: ReplicaConfiguration?
    var sms: SMSConfiguration?
    var apns: APNSConfiguration?
    var firebase: FirebaseConfiguration?
    var googleIdentityToolkit: GoogleIdentityToolkitConfiguration?
    var demoAccount: DemoAccountCredential?
    var applicationStoreLinks: ApplicationStoreLinks?
}

class MainConfiguration: Codable {
    let stage: AppStage
    let apiPath: [String]
    let domainAddress: URL
    let hostName: String
    let hostPort: Int
    let dataBaseName: String
    let dataBaseHost: String
    let dataBasePort: Int
    let dataBaseUser: String
    let dataBasePassword: String?
}

class ReplicaConfiguration: Codable {
    let replicaId: Int
}

extension Configuration {
    var replicaId: Int { return replica?.replicaId ?? 1 }
}

class SMSConfiguration: Codable {
    let sender: String
    let apiKey: String
    let templates: [SMSTemplatesType: SMSConfigurationTemplate]
}

class SMSConfigurationTemplate: Codable {
    let pattern_code: String
    let parameters: [String]
}

enum SMSTemplatesType: String, Codable {
    case register
}

class APNSConfiguration: Codable {
    let bundleId: String
    let environment: String
}

class FirebaseConfiguration: Codable {
    let bundleId: String
}

class GoogleIdentityToolkitConfiguration: Codable {
    let url: String
    let apiKey: String
}

class ApplicationStoreLinks: Codable {
    let googleStore: String?
    let myketStore: String?
}
