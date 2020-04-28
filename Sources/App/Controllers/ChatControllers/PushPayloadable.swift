//
//  PushPayloadable.swift
//  App
//
//  Created by Amir Hossein on 4/26/20.
//

import Vapor

protocol PushPayloadable: Content {
    
    var pushMainPath: String { get }
    var pushSupplementPath: String? { get }
    var pushQueryItems: [URLQueryItem] { get }
    var pushContentName: String? { get }
    
    func getClickAction(type: PushNotificationType)-> String?
    func getContent(on req: Request) throws -> Future<PushPayloadContent?>
    
}

struct PushPayloadContent {
    let name: String
    let data: String
    
    init?(name: String?, data: String?) {
        guard let name = name, let data = data else {
            return nil
        }
        self.name = name
        self.data = data
    }
}

extension PushPayloadable {
    
    func getClickAction(type: PushNotificationType)-> String? {
        var components = URLComponents()
        components.scheme = getBundleId(type: type)
        components.host = pushMainPath
        
        if let supplementPath = pushSupplementPath {
            components.path = supplementPath
        }
        components.queryItems = pushQueryItems
        
        return components.url?.absoluteString
    }
    
    func getContent(on req: Request) throws -> Future<PushPayloadContent?> {
        let name = pushContentName
        return try encode(for: req).map { response in
            guard let data = response.http.body.data else {
                return nil
            }
            guard let text = String(data: data, encoding: .utf8) else {
                return nil
            }
            return PushPayloadContent(name: name, data: text)
        }
    }
    
    private func getBundleId(type: PushNotificationType) -> String {
        let appInfo = Constants.appInfo
        switch type {
        case .APNS:
            return appInfo.apnsConfig.bundleId
        case .Firebase:
            return appInfo.firebaseConfig.bundleId
        }
    }
    
}

