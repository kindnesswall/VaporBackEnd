import Vapor
import Fluent

final class ReportGift : Model {

    static let schema = "ReportGift"

    @ID(key: .id)
    var id:UUID?

    @Field(key: "userIdOfWhoReported")
    var userIdOfWhoReported: Int

    @Field(key: "giftId")
    var giftId: Int

    @Field(key: "message")
    var message: String

    init() {}

    init(
        input: ReportGiftInput,
        userIdOfWhoReported: Int
    ) throws {
        self.userIdOfWhoReported = userIdOfWhoReported
        self.giftId = input.giftId
        self.message = input.message
    }
}

extension ReportGift : Content {}


