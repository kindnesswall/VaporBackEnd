import Vapor
import Fluent

struct ReportUserMigration: Migration {
    private let schema = "ReportUser"
    private let userIdOfWhoReported = "userIdOfWhoReported"
    private let userId = "userId"
    private let message = "message"

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .id()
            .unique(on: .id)
            .field(.string(userIdOfWhoReported), .string, .required)
            .field(.string(userId), .string, .required)
            .field(.string(message), .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .delete()
    }
}
