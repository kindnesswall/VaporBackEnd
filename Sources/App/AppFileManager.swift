//
//  AppFileManager.swift
//  App
//
//  Created by Amir Hossein on 1/16/19.
//

import Vapor

class AppFileManager: AppDirectoryDetector {
    
    enum Directory : String {
        case publicDirectory = "Public"
        case imagesDirectory = "images"
    }
    
    var appDirectoryURL : URL {
        return URL(fileURLWithPath: AppFileManager.appDirectory)
    }
    
    var appPublicDirectory : URL {
        return appendDirectory(toURL: appDirectoryURL, directory: .publicDirectory)
    }
    
    var appImagesDirecory : URL {
        return appendDirectory(toURL: appPublicDirectory, directory: .imagesDirectory)
    }
    
    func appendDirectory(toURL url:URL,directory:Directory)->URL{
        return url.appendingPathComponent(directory.rawValue)
    }
    
    func appendUserDirectory(toURL url:URL, userId:Int)->URL {
        return url.appendingPathComponent("\(userId)")
    }
    
    func createDirectoryIfDoesNotExist(path:URL) throws {
        let fileManager = FileManager()
        /// check whether directory already exists
        if !fileManager.fileExists(atPath: path.path) {
            /// create directory and name it after the users username
            try fileManager.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
        }
    }
    func saveFile(path:URL,data:Data){
        let fileManager = FileManager()
        fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
    }
    
    func getOutputImageAddress(domainAddress:URL,userId:Int,fileName:String) -> String{
        let outputImagesDirectory = appendDirectory(toURL: domainAddress, directory: .imagesDirectory)
        let outputUserImagesDirectory = appendUserDirectory(toURL: outputImagesDirectory, userId: userId)
        let outputImageAddress = outputUserImagesDirectory.appendingPathComponent(fileName)
        return outputImageAddress.absoluteString
    }
}

protocol AppDirectoryDetector {
    static var appDirectory: String { get }
}
extension AppDirectoryDetector {
    static var appDirectory: String { return DirectoryConfig.detect().workDir }
}
