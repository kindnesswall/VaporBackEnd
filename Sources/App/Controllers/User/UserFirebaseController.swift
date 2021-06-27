//
//  UserFirebaseController.swift
//  App
//
//  Created by Amir Hossein on 11/5/19.
//

import Vapor


class UserFirebaseController: UserControllerCore {
    
    func loginUser(_ req: Request) throws -> EventLoopFuture<AuthOutput> {
        
        return try req.content.decode(Inputs.FirebaseLogin.self).flatMap { input in

            return try self.sendFirebaseRequest(req, idToken: input.idToken).flatMap({ phoneNumber in
                
                guard let phoneNumber = phoneNumber else {
                    throw Abort(.firebaseAuthenticationError)
                }
                
                return self.findOrCreateUser(req: req, phoneNumber: phoneNumber).flatMap({ user in
                    return try self.getToken(req: req, user: user)
                })
            })

        }
        
    }
    
    private func sendFirebaseRequest(_ req: Request, idToken:String) -> EventLoopFuture<String?> {
        
        let apiInput = Inputs.FirebaseLogin(idToken: idToken)
        guard let configuration = configuration.googleIdentityToolkit else {
            return req.db.makeFailedFuture(.failedToLoginWithFirebase)
        }
        let url = "\(configuration.url)\(configuration.apiKey)"
        
        return APICall.call(
            req: req,
            url: url,
            httpMethod: .POST,
            input: apiInput).map { response in
                let output = try? response.content.decode(FirebaseAuthOutput.self)
                let user = output?.users.first
                let phoneNumber = user?.phoneNumber
                return phoneNumber
        }
    }
}
