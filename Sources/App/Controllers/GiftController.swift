//
//  GiftController.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor

/// Controls basic CRUD operations on `Gift`s.
final class GiftController {
    
    /// Returns a list of all `Gift`s.
    func index(_ req: Request) throws -> Future<[Gift]> {
        return Gift.query(on: req).all()
    }
    
    /// Saves a decoded `Gift` to the database.
    func create(_ req: Request) throws -> Future<Gift> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Gift.self).flatMap { gift in
            gift.userId = user.id
            return gift.save(on: req)
        }
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            guard let userId = user.id , userId == gift.userId else {
                throw Constants.errors.unAuthorizedGift
            }
            return gift.delete(on: req)
            }.transform(to: .ok)
    }
    
    func filteredByCategory(_ req: Request) throws -> Future<[Gift]> {
        return try req.parameters.next(Category.self).flatMap { category in
            return try category.gifts.query(on: req).all()
        }
    }
    
    func filteredByOwner(_ req: Request) throws -> Future<[Gift]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.gifts.query(on: req).all()
    }
    
    func uploadImage(_ req: Request) throws -> Future<ImageOutput> {
        
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.invalidUserId
        }
        
        return try req.content.decode(ImageInput.self).map({ (imageInput) -> ImageOutput in
            let appDirectory = AppFileManager()
            let imageDirectory = appDirectory.appendUserDirectory(toURL: appDirectory.appImagesDirecory, userId: userId)
            try appDirectory.createDirectoryIfDoesNotExist(path: imageDirectory)
            let imageAddress = imageDirectory.appendingPathComponent(imageInput.image.filename)
            appDirectory.saveFile(path: imageAddress, data: imageInput.image.data)
            
            let imageOutputAddress = appDirectory.getOutputImageAddress(domainAddress: Constants.domainAddress, userId: userId, fileName: imageInput.image.filename)
            
            return ImageOutput(address: imageOutputAddress)
        })
        
    }
    
}
