//
//  PushPayload.swift
//  App
//
//  Created by Amir Hossein on 7/1/19.
//

import Foundation

class PushPayload : Codable {
    let aps: PushPayloadAPS
    
    init(alert: String, sound: String = "default") {
        self.aps = PushPayloadAPS(alert: alert, sound: sound)
    }
    
    var textFormat: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let text = String(data: data, encoding: .utf8)
        return text
    }
}

class PushPayloadAPS: Codable {
    var alert: String
    var sound: String
    
    init(alert: String, sound: String) {
        self.alert = alert
        self.sound = sound
    }
}

