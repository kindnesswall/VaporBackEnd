import FluentPostgreSQL

final class AddGiftPhoneVisibility: Migration {
    typealias Database = PostgreSQLDatabase

    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(Gift.self, on: conn) { builder in
            builder.field(for: \.isPhoneVisibleForCharities)
            builder.field(for: \.isPhoneVisibleForAll)
        }
    }

    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return PostgreSQLDatabase.update(Gift.self, on: conn) { builder in
            builder.deleteField(for: \.isPhoneVisibleForCharities)
            builder.deleteField(for: \.isPhoneVisibleForAll)
        }
    }
}
