

import Vapor
import Fluent

struct PhoneNumberActivationCodeUniquePhoneNumberMigration: Migration {
    
    private let schema = "PhoneNumberActivationCode"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .unique(on: "phoneNumber")
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .deleteUnique(on: "phoneNumber")
            .update()
    }
}
