//
//  GiftRequestStatusEnumMigration.swift
//  
//
//  Created by AmirHossein on 7/23/22.
//

import Vapor
import Fluent

struct GiftRequestStatusEnumMigration: Migration {
    private let schema = "GiftRequest"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum("Status")
            .case("isWaiting")
            .case("wasReceived")
            .case("wasCenceled")
            .create().flatMap { Status in
                database.schema(schema)
                    .field("status", Status)
                    .update().flatMap {
                        database.enum("CancellationReason")
                            .case("didNotResponse")
                            .case("otherReasons")
                            .create().flatMap { CancellationReason in
                                database.schema(schema)
                                    .field("cancellationReason", CancellationReason)
                                    .update()
                            }
                    }
            }
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .deleteField("status")
            .update().flatMap {
                database.enum("Status")
                    .delete().flatMap {
                        database.schema(schema)
                            .deleteField("cancellationReason")
                            .update().flatMap {
                                database.enum("CancellationReason")
                                    .delete()
                            }
                    }
            }
    }
}
