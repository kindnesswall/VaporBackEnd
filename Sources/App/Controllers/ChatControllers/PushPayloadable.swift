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
    
    func getClickAction(type: PushNotificationType) throws -> String?
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
    
    func getClickAction(type: PushNotificationType) throws -> String? {
        var components = URLComponents()
        components.scheme = try getBundleId(type: type)
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
    
    private func getBundleId(type: PushNotificationType) throws -> String {
        switch type {
        case .APNS:
            guard let bundleId = configuration.apns?.bundleId else {
                throw Abort(.failedToSendAPNSPush)
            }
            return bundleId
        case .Firebase:
            guard let bundleId = configuration.firebase?.bundleId else {
                throw Abort(.failedToSendFirebasePush)
            }
            return bundleId
        }
    }
    
}

