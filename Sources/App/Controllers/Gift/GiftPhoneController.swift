import Vapor

class GiftPhoneController {

    func getUserPhoneRequest(_ req: Request) throws -> Future<String> {

        let auth = try req.requireAuthenticated(User.self)
        let isAdmin = auth.isAdmin
        let isCharity = auth.isCharity
        let giftId = try req.parameters.next(Int.self)

        return Gift.get(giftId, on: req).flatMap { gift in
            guard isAdmin || gift.isPhoneVisibleForAll || (isCharity && gift.isPhoneVisibleForCharities) else {
                throw Abort(.userAccessIsDenied)
            }
            return gift.user.get(on: req).map { user in
                return user.phoneNumber
            }
        }
    }
}
