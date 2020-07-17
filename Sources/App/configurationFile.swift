//
//  configurationFile.swift
//  App
//
//  Created by Amir Hossein on 3/7/20.
//

import Foundation

var configuration: Configuration?
var replicaId : Int {
    return configuration?.replicaId ?? 1
}

public func readConfiguration() {
    let rootPath = Constants.appInfo.rootPath
    let configFile = Constants.appInfo.configFile
    let path = "\(rootPath)\(configFile)"
    let url = URL(fileURLWithPath: path)
    guard let data = try? Data(contentsOf: url) else {return}
    configuration = try? JSONDecoder().decode(Configuration.self, from: data)
}

public func checkDirectories() {
    LogDirectory().check()
}

