//
//  Sponsor.swift
//  App
//
//  Created by Amir Hossein on 8/24/20.
//

import Vapor
import FluentPostgreSQL

final class Sponsor: PostgreSQLModel {
    var id: Int?
    var name: String
    var image: String?
    var description: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    func update(input: Sponsor, on req: Request) -> Future<HTTPStatus> {
        self.name = input.name
        self.image = input.image
        self.description = input.description
        return update(on: req).transform(to: .ok)
    }

}

extension Sponsor {
    static func get(_ id: Int, on conn: DatabaseConnectable) -> Future<Sponsor> {
        return find(id, on: conn).unwrap(or: Abort(.notFound))
    }
}

extension Sponsor {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension Sponsor {
    var isValid: Bool {
        return true
    }
}

extension Sponsor : Migration {}

extension Sponsor : Content {}

extension Sponsor : Parameter {}

