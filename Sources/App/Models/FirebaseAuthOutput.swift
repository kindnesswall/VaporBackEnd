//
//  FirebaseAuthOutput.swift
//  App
//
//  Created by Amir Hossein on 11/5/19.
//

import Foundation


class FirebaseAuthOutput: Codable {
    var users: [FirebaseAuthUser]
}

class FirebaseAuthUser: Codable {
    var phoneNumber: String
}
