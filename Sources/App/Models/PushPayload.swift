//
//  PushPayload.swift
//  App
//
//  Created by Amir Hossein on 7/1/19.
//

import Foundation

class PushPayload : Codable {
    let aps: PushPayloadAPS
    let data: String?
    
    init(title:String?, body:String?, data: String?, sound: String? = nil) {
        let alert = PushPayloadAPS.Alert(title: title, body: body)
        self.aps = PushPayloadAPS(alert: alert, sound: sound)
        self.data = data
    }
    
    var textFormat: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let text = String(data: data, encoding: .utf8)
        return text
    }
}

class PushPayloadAPS: Codable {
    var alert: Alert
    var sound: String?
    
    init(alert: Alert, sound: String?) {
        self.alert = alert
        self.sound = sound
    }
    
    class Alert: Codable {
        var title:String?
        var body:String?
        
        init(title:String?,body:String?) {
            self.title = title
            self.body = body
        }
    }
}

