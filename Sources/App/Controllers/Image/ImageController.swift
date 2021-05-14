//
//  ImageController.swift
//  App
//
//  Created by Amir Hossein on 2/4/19.
//

import Vapor

final class ImageController {
    
    func uploadImage(_ req: Request) throws -> ImageOutput {
        
        let auth = try req.auth.require(User.self)
        let authId = try auth.getId()
        
        let imageInput = try req.content.decode(ImageInput.self)
        
        let imageFormat = imageInput.imageFormat ?? "jpeg"
        let imageName = "image_\(String.getCurrentDate(withClock: true)).\(imageFormat)"
        
        let appDirectory = AppFileManager()
        let imageDirectory = appDirectory.appendUserDirectory(toURL: appDirectory.appImagesDirecory, userId: authId)
        try appDirectory.createDirectoryIfDoesNotExist(path: imageDirectory)
        let imageAddress = imageDirectory.appendingPathComponent(imageName)
        appDirectory.saveFile(path: imageAddress, data: imageInput.image)
        
        let imageOutputAddress = appDirectory.getOutputImageAddress(domainAddress: configuration.main.domainAddress, userId: authId, fileName: imageName)
        
        return ImageOutput(address: imageOutputAddress)
        
    }
}
