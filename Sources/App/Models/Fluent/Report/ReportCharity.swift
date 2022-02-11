import Vapor
import Fluent

final class ReportCharity : Model {

    static let schema = "ReportCharity"

    @ID(key: .id)
    var id:UUID?

    @Field(key: "userIdOfWhoReported")
    var userIdOfWhoReported: Int

    @Field(key: "charityId")
    var charityId: Int

    @Field(key: "message")
    var message: String

    init() {}

    init(
        input: ReportCharityInput,
        userIdOfWhoReported: Int
    ) throws {
        self.userIdOfWhoReported = userIdOfWhoReported
        self.charityId = input.charityId
        self.message = input.message
    }
}

extension ReportCharity : Content {}
