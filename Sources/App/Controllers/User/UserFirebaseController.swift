//
//  UserFirebaseController.swift
//  App
//
//  Created by Amir Hossein on 11/5/19.
//

import Vapor


class UserFirebaseController: UserControllerCore {
    
    func loginUser(_ req: Request) throws -> Future<AuthOutput> {
        
        return try req.content.decode(Inputs.FirebaseLogin.self).flatMap { input in

            return try self.sendFirebaseRequest(req, idToken: input.idToken).flatMap({ phoneNumber in
                
                guard let phoneNumber = phoneNumber else {
                    throw Constants.errors.firebaseAuthenticationError
                }
                
                return self.findOrCreateUser(req: req, phoneNumber: phoneNumber).flatMap({ user in
                    return try self.getToken(req: req, user: user)
                })
            })

        }
        
    }
    
    private func sendFirebaseRequest(_ req: Request, idToken:String) throws -> Future<String?> {
        
        let apiInput = Inputs.FirebaseLogin(idToken: idToken)
        let url = "\(Constants.appInfo.identityToolkitConfig.url)\(Constants.appInfo.identityToolkitConfig.apiKey)"
        
        return try APICurl.curl(req: req, url: url, httpMethod: .POST, input: apiInput).map({ data in
            
            APICurl.log(data: data)
            
            let output = try? JSONDecoder().decode(FirebaseAuthOutput.self, from: data)
            let user = output?.users.first
            let phoneNumber = user?.phoneNumber
            return phoneNumber
        })
    }
}
