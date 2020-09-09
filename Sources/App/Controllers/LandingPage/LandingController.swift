//
//  LandingController.swift
//  App
//
//  Created by Amir Hossein on 9/9/20.
//

import Vapor
import Leaf

final class LandingController {
    
    func present(_ req: Request) throws -> Future<View> {
        
        let googleStore = "https://play.google.com/store/apps/details?id=com.kindnesswand"
        
        let information = LandingPageInformation(googleStore: googleStore)
        
        return try req.view().render("landing",information)
    }
    
    func redirectHome(_ req: Request) throws -> Response {
        return req.redirect(to: URIs().home)
    }
}
