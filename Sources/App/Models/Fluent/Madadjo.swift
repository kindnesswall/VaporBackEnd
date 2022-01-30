import Vapor
import Fluent

final class Madadjo : Model {

    static let schema = "Madadjo"

    @ID(key: .id)
    var id:UUID?

    @Field(key: "nationalCode")
    var nationalCode: String

    @Field(key: "fullName")
    var fullName: String

    @Field(key: "isHeadOfHousehold")
    var isHeadOfHousehold: Bool

    @OptionalField(key: "headOfHouseholdId")
    var headOfHouseholdId: UUID?

    init() {}
}

extension Madadjo : Content {}


