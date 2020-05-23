//
//  ApplicationVersion.swift
//  App
//
//  Created by Amir Hossein on 5/23/20.
//

import Vapor
import FluentPostgreSQL

final class ApplicationVersion: PostgreSQLModel {
    var id: Int?
    var platform: String
    var availableVersion: String
    var requiredVersion: String
    var downloadLink: String
    
    
    init(platform: PlatformType, input: Inputs.ApplicationVersion) {
        self.platform = platform.rawValue
        self.availableVersion = input.availableVersion
        self.requiredVersion = input.requiredVersion
        self.downloadLink = input.downloadLink
    }
    
    func update(input: Inputs.ApplicationVersion, on conn: DatabaseConnectable) -> Future<ApplicationVersion> {
        self.availableVersion = input.availableVersion
        self.requiredVersion = input.requiredVersion
        self.downloadLink = input.downloadLink
        return save(on: conn)
    }
}

enum PlatformType: String {
    case iOS
    case android
}

extension ApplicationVersion {
    static func get(platform: PlatformType, on conn: DatabaseConnectable) -> Future<ApplicationVersion> {
        return query(on: conn).filter(\.platform == platform.rawValue).first().map { item in
            guard let item = item else {
                throw Constants.errors.notFound
            }
            return item
        }
    }
    static func update(platform: PlatformType, input: Inputs.ApplicationVersion, on conn: DatabaseConnectable) -> Future<ApplicationVersion> {
        return get(platform: platform, on: conn).flatMap { item in
            return item.update(input: input, on: conn)
        }
    }
}

extension ApplicationVersion : Migration {}

extension ApplicationVersion : Content {}

extension ApplicationVersion : Parameter {}
