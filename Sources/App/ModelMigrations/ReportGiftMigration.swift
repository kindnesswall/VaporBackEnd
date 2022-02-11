import Vapor
import Fluent

struct ReportGiftMigration: Migration {
    private let schema = "ReportGift"
    private let userIdOfWhoReported = "userIdOfWhoReported"
    private let giftId = "giftId"
    private let message = "message"

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .id()
            .unique(on: .id)
            .field(.string(userIdOfWhoReported), .string, .required)
            .field(.string(giftId), .string, .required)
            .field(.string(message), .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .delete()
    }
}
