//
//  ApplicationVersionSeed.swift
//  App
//
//  Created by Amir Hossein on 5/23/20.
//

import FluentPostgreSQL

final class ApplicationVersionSeed: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static let seeds = [
        ApplicationVersion(platform: .iOS, input: Inputs.ApplicationVersion(availableVersion: "1.0.0", requiredVersion: "1.0.0", downloadLink: "http://dev.kindnesswand.com")),
        ApplicationVersion(platform: .android, input: Inputs.ApplicationVersion(availableVersion: "1.0.0", requiredVersion: "1.0.0", downloadLink: "http://dev.kindnesswand.com"))
    ]
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = seeds.map { seed in
            return seed.create(on: conn).map(to: Void.self) { _ in return }
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
    }
}
