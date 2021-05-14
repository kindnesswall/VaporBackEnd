//
//  LandingController.swift
//  App
//
//  Created by Amir Hossein on 9/9/20.
//

import Vapor
import Leaf

final class LandingController {
    
    func present(_ req: Request) throws -> EventLoopFuture<View> {
        
        let storeLinks = configuration.applicationStoreLinks
        
        let information = LandingPageInformation(
            googleStore: storeLinks?.googleStore,
            myketStore: storeLinks?.myketStore)
        
        return try req.view().render("landing",information)
    }
    
    func redirectHome(_ req: Request) throws -> Response {
        return req.redirect(to: URIs().home)
    }
}
