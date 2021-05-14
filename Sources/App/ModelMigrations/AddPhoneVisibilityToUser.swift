import Fluent
import FluentPostgresDriver

final class AddPhoneVisibilityToUser: Migration {
    typealias Database = PostgreSQLDatabase

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(User.self, on: conn) { builder in
            builder.field(for: \.isPhoneVisibleForCharities)
            builder.field(for: \.isPhoneVisibleForAll)
        }
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(User.self, on: conn) { builder in
            builder.deleteField(for: \.isPhoneVisibleForCharities)
            builder.deleteField(for: \.isPhoneVisibleForAll)
        }
    }
}
