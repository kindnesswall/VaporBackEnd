import Vapor
import Fluent
import FluentPostgresDriver

class ReportGiftController {
    func report(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let auth = try req.auth.require(User.self)
        let authId = try auth.getId()
        let reportGiftInput = try req.content.decode(ReportGiftInput.self)

        return try ReportGift(input: reportGiftInput, userIdOfWhoReported: authId).save(on: req.db).transform(to: .ok)
    }
}
