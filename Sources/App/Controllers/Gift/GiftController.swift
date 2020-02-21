//
//  GiftController.swift
//  App
//
//  Created by Amir Hossein on 1/11/19.
//

import Vapor
import FluentPostgreSQL

/// Controls basic CRUD operations on `Gift`s.
final class GiftController {
    
    /// Returns a list of all `Gift`s.
    func index(_ req: Request) throws -> Future<[Gift]> {
        
        return try req.content.decode(RequestInput.self).flatMap { requestInput in
            let query = Gift.query(on: req)
            return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: true, onlyReviewedGifts: true)
        }
        
    }
    
    func registeredGifts(_ req: Request) throws -> Future<[Gift]> {
        
        
        
        return try req.parameters.next(User.self).flatMap({ selectedUser in
            
            guard let selectedUserId = selectedUser.id else {
                throw Constants.errors.nilUserId
            }
            
            let authUser = try req.requireAuthenticated(User.self)
            let isAdmin = authUser.isAdmin
            var isOwner = false
            if let authUserId = authUser.id,
                authUserId == selectedUserId {
                isOwner = true
            }
            
            
            return try req.content.decode(RequestInput.self).flatMap({ requestInput in
                
                let query = Gift.query(on: req, withSoftDeleted: (isAdmin || isOwner))
                .filter(\.userId == selectedUserId)
                
                if (isOwner && !isAdmin) {
                    query.filter(\.isDeleted == false)
                }
                
                return Gift.getGiftsWithRequestFilter(query: query, requestInput: requestInput,onlyUndonatedGifts: true, onlyReviewedGifts: !(isAdmin || isOwner))
            })
            
            
        })
        
    }
    
    /// Saves a decoded `Gift` to the database.
    func create(_ req: Request) throws -> Future<Gift> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Gift.Input.self).flatMap { inputGift in
            let gift = Gift(userId: user.id, gift: inputGift)
            return try self.setNamesAndSave(req, gift: gift)
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
                return try self.setNamesAndSave(req, gift: gift)
            }
            
        }
        
    }
    
    private func setNamesAndSave(_ req: Request, gift: Gift) throws ->  Future<Gift> {
        return try gift.getCountry(req).flatMap { country in
            return gift.getCategoryTitle(req, country: country).flatMap { categoryTitle in
                return gift.province.get(on: req).flatMap { province in
                    return gift.city.get(on: req).flatMap { city in
                        gift.categoryTitle = categoryTitle
                        gift.provinceName = province.name
                        gift.cityName = city.name
                        return self.setRegionNameAndSave(req, gift: gift)
                    }
                }
            }
        }
    }
    
    private func setRegionNameAndSave(_ req: Request, gift: Gift) -> Future<Gift> {
        
        if let region = gift.region {
            return region.get(on: req).flatMap { region in
                gift.regionName = region.name
                return gift.save(on: req)
            }
        } else {
            gift.regionName = nil
            return gift.save(on: req)
        }
    }
    
    /// Deletes a parameterized `Gift`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Gift.self).flatMap { (gift) -> Future<Void> in
            guard let userId = user.id , userId == gift.userId else {
                throw Constants.errors.unauthorizedGift
            }
            gift.isDeleted = true
            return gift.save(on: req).flatMap({ gift in
                return gift.delete(on: req)
            })
            }.transform(to: .ok)
    }
    
}
