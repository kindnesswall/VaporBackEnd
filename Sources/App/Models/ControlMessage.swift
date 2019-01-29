//
//  ControlMessage.swift
//  App
//
//  Created by Amir Hossein on 1/29/19.
//

import Foundation

final class ControlMessage : Codable {
    var type:ControlMessageType
    
    init(type:ControlMessageType) {
        self.type=type
    }
}

enum ControlMessageType : String,Codable {
    case ready
    case fetch
}
