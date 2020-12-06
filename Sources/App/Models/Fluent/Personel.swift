import Vapor
import FluentPostgreSQL

final class Personel: PostgreSQLModel {
    var id:Int?
    var name:String
}

extension Personel : Migration {}

extension Personel : Content {}

extension Personel : Parameter {}
