//
//  ApplicationVersion.swift
//  App
//
//  Created by Amir Hossein on 5/23/20.
//

import Vapor
import Fluent


final class ApplicationVersion: Model {
    
    static let schema = "ApplicationVersion"
    
    @ID(key: .id)
    var id: Int?
    
    @Field(key: "platform")
    var platform: String
    
    @Field(key: "availableVersionName")
    var availableVersionName: String
    
    @Field(key: "availableVersionCode")
    var availableVersionCode: Int
    
    @Field(key: "requiredVersionName")
    var requiredVersionName: String
    
    @Field(key: "requiredVersionCode")
    var requiredVersionCode: Int
    
    @OptionalField(key: "downloadLink")
    var downloadLink: String?
    
    init() {}
    
    init(platform: PlatformType, input: Inputs.ApplicationVersion) {
        self.platform = platform.rawValue
        self.availableVersionName = input.availableVersionName
        self.availableVersionCode = input.availableVersionCode
        self.requiredVersionName = input.requiredVersionName
        self.requiredVersionCode = input.requiredVersionCode
        self.downloadLink = input.downloadLink
    }
    
    func update(input: Inputs.ApplicationVersion, on conn: Database) -> EventLoopFuture<ApplicationVersion> {
        self.availableVersionName = input.availableVersionName
        self.availableVersionCode = input.availableVersionCode
        self.requiredVersionName = input.requiredVersionName
        self.requiredVersionCode = input.requiredVersionCode
        self.downloadLink = input.downloadLink
        return save(on: conn).transform(to: self)
    }
}

enum PlatformType: String {
    case iOS
    case android
}

extension ApplicationVersion {
    static func get(platform: PlatformType, on conn: Database) -> EventLoopFuture<ApplicationVersion> {
        return query(on: conn)
            .filter(\.$platform == platform.rawValue)
            .first()
            .flatMapThrowing { item in
            guard let item = item else {
                throw Abort(.notFound)
            }
            return item
        }
    }
    static func update(platform: PlatformType, input: Inputs.ApplicationVersion, on conn: Database) -> EventLoopFuture<ApplicationVersion> {
        return get(platform: platform, on: conn).flatMap { item in
            return item.update(input: input, on: conn)
        }
    }
}

//extension ApplicationVersion : Migration {}

extension ApplicationVersion : Content {}

