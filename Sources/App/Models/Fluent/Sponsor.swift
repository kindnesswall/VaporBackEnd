//
//  Sponsor.swift
//  App
//
//  Created by Amir Hossein on 8/24/20.
//

import Vapor
import Fluent

final class Sponsor: Model {
    
    static let schema = "Sponsor"
    
    var id: Int?
    var name: String
    var image: String?
    var description: String?
    var estimatedDonation: Double?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    func update(input: Sponsor, on req: Request) -> EventLoopFuture<HTTPStatus> {
        self.name = input.name
        self.image = input.image
        self.description = input.description
        self.estimatedDonation = input.estimatedDonation
        return update(on: req).transform(to: .ok)
    }

}

extension Sponsor {
    static func get(_ id: Int, on conn: Database) -> EventLoopFuture<Sponsor> {
        return find(id, on: conn).unwrap(or: Abort(.notFound))
    }
}

extension Sponsor {
    var isValid: Bool {
        return true
    }
}

//extension Sponsor : Migration {}

extension Sponsor : Content {}



