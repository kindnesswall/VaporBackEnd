import Vapor
import Fluent

struct MadadjoMigration: Migration {
    private let schema = "Madadjo"
    private let nationalCode = "nationalCode"
    private let fullName = "fullName"
    private let isHeadOfHousehold = "isHeadOfHousehold"
    private let headOfHouseholdId = "HeadOfHouseholdId"

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .id()
            .field(.string(nationalCode), .string, .required)
            .unique(on: .string(nationalCode))
            .field(.string(fullName), .string, .required)
            .field(.string(isHeadOfHousehold), .bool, .required)
            .field(.string(headOfHouseholdId), .uuid)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(schema)
            .delete()
    }
}
