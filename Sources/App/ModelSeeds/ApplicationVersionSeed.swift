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
        ApplicationVersion(platform: .iOS, input: Inputs.ApplicationVersion(availableVersionName: "1.0.0", availableVersionCode: 1, requiredVersionName: "1.0.0", requiredVersionCode: 1)),
        ApplicationVersion(platform: .android, input: Inputs.ApplicationVersion(availableVersionName: "1.0.0", availableVersionCode: 1, requiredVersionName: "1.0.0", requiredVersionCode: 1))
    ]
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = seeds.map { seed in
            return seed.create(on: conn).map(to: Void.self) { _ in return }
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return conn.eventLoop.newSucceededFuture(result: Void())
    }
}
