//
//  ApplicationVersionSeed.swift
//  App
//
//  Created by Amir Hossein on 5/23/20.
//

import Fluent
import FluentPostgresDriver

final class ApplicationVersionSeed: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static let seeds = [
        ApplicationVersion(platform: .iOS, input: Inputs.ApplicationVersion(availableVersionName: "1.0.0", availableVersionCode: 1, requiredVersionName: "1.0.0", requiredVersionCode: 1, downloadLink: nil)),
        ApplicationVersion(platform: .android, input: Inputs.ApplicationVersion(availableVersionName: "1.0.0", availableVersionCode: 1, requiredVersionName: "1.0.0", requiredVersionCode: 1, downloadLink: nil))
    ]
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = seeds.map { seed in
            return seed.create(on: conn).map(to: Void.self) { _ in return }
        }
        return EventLoopFuture<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return conn.future(Void())
    }
}
