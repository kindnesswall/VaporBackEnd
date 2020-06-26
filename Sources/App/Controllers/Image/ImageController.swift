//
//  ImageController.swift
//  App
//
//  Created by Amir Hossein on 2/4/19.
//

import Vapor

final class ImageController {
    
    func uploadImage(_ req: Request) throws -> Future<ImageOutput> {
        
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Abort(.nilUserId)
        }
        
        return try req.content.decode(ImageInput.self).map({ (imageInput) -> ImageOutput in
            
            let imageFormat = imageInput.imageFormat ?? "jpeg"
            let imageName = "image_\(String.getCurrentDate()).\(imageFormat)"
            
            let appDirectory = AppFileManager()
            let imageDirectory = appDirectory.appendUserDirectory(toURL: appDirectory.appImagesDirecory, userId: userId)
            try appDirectory.createDirectoryIfDoesNotExist(path: imageDirectory)
            let imageAddress = imageDirectory.appendingPathComponent(imageName)
            appDirectory.saveFile(path: imageAddress, data: imageInput.image)
            
            let imageOutputAddress = appDirectory.getOutputImageAddress(domainAddress: Constants.appInfo.domainAddress, userId: userId, fileName: imageName)
            
            return ImageOutput(address: imageOutputAddress)
        })
        
    }
}
