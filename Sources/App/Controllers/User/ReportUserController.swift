import Vapor
import Fluent
import FluentPostgresDriver

class ReportUserController {
    func report(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let auth = try req.auth.require(User.self)
        let authId = try auth.getId()
        let reportUserInput = try req.content.decode(ReportUserInput.self)

        return try ReportUser(input: reportUserInput, userIdOfWhoReported: authId).save(on: req.db).transform(to: .ok)
    }
}
