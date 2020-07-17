//
//  LogDirectory.swift
//  App
//
//  Created by Amir Hossein on 7/17/20.
//

import Foundation

struct LogDirectory {
    
    func check() {
        let fileManager = AppFileManager()
        try? fileManager.createDirectoryIfDoesNotExist(path: directoryPath)
    }
    
    var filePath: URL {
        let date = String.getCurrentDate(withClock: false)
        let fileName = "\(date).\(logConfig.fileExtension)"
        let url = directoryPath.appendingPathComponent(fileName)
        return url
    }
    
    private var directoryPath: URL {
        let path = "\(appInfo.rootPath)\(logConfig.path)\(replicaId)"
        let url = URL(fileURLWithPath: path)
        return url
    }
    
    private var logConfig: LogConfig {
        return appInfo.logConfig
    }
    
    private var appInfo: AppInfo {
        return Constants.appInfo
    }
    
}
