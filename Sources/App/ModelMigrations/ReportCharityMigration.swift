import Vapor
import Fluent

struct ReportCharityMigration: Migration {
    private let schema = "ReportCharity"
    private let userIdOfWhoReported = "userIdOfWhoReported"
    private let charityId = "charityId"
    private let message = "message"

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .id()
            .unique(on: .id)
            .field(.string(userIdOfWhoReported), .string, .required)
            .field(.string(charityId), .string, .required)
            .field(.string(message), .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .delete()
    }
}
