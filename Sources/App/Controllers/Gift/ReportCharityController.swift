import Vapor
import Fluent
import FluentPostgresDriver

class ReportCharityController {
    func report(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let auth = try req.auth.require(User.self)
        let authId = try auth.getId()
        let reportCharityInput = try req.content.decode(ReportCharityInput.self)

        return try ReportCharity(input: reportCharityInput, userIdOfWhoReported: authId).save(on: req.db).transform(to: .ok)
    }
}
