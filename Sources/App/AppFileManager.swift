//
//  AppFileManager.swift
//  App
//
//  Created by Amir Hossein on 1/16/19.
//

import Vapor

class AppFileManager {
    
    enum Directory : String {
        case publicDirectory = "public"
        case imagesDirectory = "images"
    }
    
    var appDirectory : URL {
        let directory = DirectoryConfig.detect().workDir
        return URL(fileURLWithPath: directory)
    }
    
    var appPublicDirectory : URL {
        return appendDirectory(toURL: appDirectory, directory: .publicDirectory)
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
