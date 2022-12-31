//
//  configurationFile.swift
//  App
//
//  Created by Amir Hossein on 3/7/20.
//

import Foundation

var configuration = Configuration()

public func readConfigurations() {
    
    do {
        configuration.main = try load(path: .main, type: MainConfiguration.self)
    } catch {
        fatalError("Config file error: \(error)")
    }
    
    configuration.replica = try? load(path: .replica, type: ReplicaConfiguration.self)
    
    configuration.sms = try? load(path: .sms, type: SMSConfiguration.self)
    configuration.apns = try? load(path: .apns, type: APNSConfiguration.self)
    configuration.firebase = try? load(path: .firebase, type: FirebaseConfiguration.self)
    configuration.googleIdentityToolkit = try? load(path: .googleIdentityToolkit, type: GoogleIdentityToolkitConfiguration.self)
    configuration.demoAccount = try? load(path: .demoAccount, type: DemoAccountCredential.self)
    configuration.applicationStoreLinks = try? load(path: .applicationStoreLinks, type: ApplicationStoreLinks.self)
}

private func load<T: Codable>(path: ConfigurationsPaths.FileType, type: T.Type) throws -> T {
    let path = ConfigurationsPaths.path(of: path)
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(type, from: data)
}

public func checkDirectories() {
    LogDirectory().check()
}

