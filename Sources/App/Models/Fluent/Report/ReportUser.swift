import Vapor
import Fluent

final class ReportUser : Model {

    static let schema = "ReportUser"

    @ID(key: .id)
    var id:UUID?

    @Field(key: "userIdOfWhoReported")
    var userIdOfWhoReported: Int

    @Field(key: "userId")
    var userId: Int

    @Field(key: "message")
    var message: String

    init() {}

    init(
        input: ReportUserInput,
        userIdOfWhoReported: Int
    ) throws {
        self.userIdOfWhoReported = userIdOfWhoReported
        self.userId = input.userId
        self.message = input.message
    }
}

extension ReportUser : Content {}


