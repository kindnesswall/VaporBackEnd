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
        
        return try req.content.decode(RequestRange.self).flatMap { requestRange in
            let query = Gift.query(on: req)
            return Gift.getGiftsWithRangeFilter(query: query, requestRange: requestRange)
        }
        
    }
    
    func filteredByCategory(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.parameters.next(Category.self).flatMap { category in
            
            return try req.content.decode(RequestRange.self).flatMap({ requestRange in
                let query = try category.gifts.query(on: req)
                return Gift.getGiftsWithRangeFilter(query: query, requestRange: requestRange)
            })
            
        }
    }
    
    func filteredByOwner(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.content.decode(RequestRange.self).flatMap({ requestRange in
            let user = try req.requireAuthenticated(User.self)
            let query = try user.gifts.query(on: req)
            return Gift.getGiftsWithRangeFilter(query: query, requestRange: requestRange)
        })
        
    }
    
    /// Saves a decoded `Gift` to the database.
    func create(_ req: Request) throws -> Future<Gift> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Gift.Input.self).flatMap { inputGift in
            
            let gift = Gift(userId: user.id, gift: inputGift)
            
            return gift.save(on: req)
        }
    }
    
    func update(_ req: Request) throws -> Future<Gift> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Gift> in
            guard let userId = user.id , userId == gift.userId else {
                throw Constants.errors.unauthorizedGift
            }
            
            return try req.content.decode(Gift.Input.self).flatMap { inputGift -> Future<Gift> in
                
                gift.update(gift: inputGift)
                return gift.save(on: req)
            }
            
        }
        
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            guard let userId = user.id , userId == gift.userId else {
                throw Constants.errors.unauthorizedGift
            }
            return gift.delete(on: req)
            }.transform(to: .ok)
    }
    
    
    func uploadImage(_ req: Request) throws -> Future<ImageOutput> {
        
        let user = try req.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Constants.errors.nilUserId
        }
        
        return try req.content.decode(ImageInput.self).map({ (imageInput) -> ImageOutput in
            
            let imageFormat = imageInput.imageFormat ?? "jpeg"
            let imageName = "image_\(String.getCurrentDate()).\(imageFormat)"
            
            let appDirectory = AppFileManager()
            let imageDirectory = appDirectory.appendUserDirectory(toURL: appDirectory.appImagesDirecory, userId: userId)
            try appDirectory.createDirectoryIfDoesNotExist(path: imageDirectory)
            let imageAddress = imageDirectory.appendingPathComponent(imageName)
            appDirectory.saveFile(path: imageAddress, data: imageInput.image)

            let imageOutputAddress = appDirectory.getOutputImageAddress(domainAddress: Constants.domainAddress, userId: userId, fileName: imageName)
            
            return ImageOutput(address: imageOutputAddress)
        })
        
    }
    
}
