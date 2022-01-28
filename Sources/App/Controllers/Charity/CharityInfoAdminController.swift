//
//  CharityInfoAdminController.swift
//  
//
//  Created by Amir Hossein on 1/28/22.
//

import Vapor

final class CharityInfoAdminController {
    
    func forceCreate(_ req: Request) throws -> EventLoopFuture<Charity> {
        
        // This function must be admin protected!
        let userId = try req.requireIDParameter()
        let input = try req.content.decode(Charity.Input.self)
        
        let charity = Charity(input: input, userId: userId)
        
        return charity.save(on: req.db)
            .transform(to: charity)
    }
}
