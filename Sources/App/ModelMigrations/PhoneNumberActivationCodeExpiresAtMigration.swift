

import Vapor
import Fluent

struct PhoneNumberActivationCodeExpiresAtMigration: Migration {
    private let schema = "PhoneNumberActivationCode"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .field("activationCodeExpiresAt", .datetime)
            .update()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteField("activationCodeExpiresAt")
            .update()
    }
}
