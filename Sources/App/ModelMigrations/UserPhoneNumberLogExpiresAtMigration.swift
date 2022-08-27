

import Vapor
import Fluent

struct UserPhoneNumberLogExpiresAtMigration: Migration {
    private let schema = "UserPhoneNumberLog"
    
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
