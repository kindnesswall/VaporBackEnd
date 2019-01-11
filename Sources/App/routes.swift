import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    
    let uris = URIs(apiRoute: Constants.apiRoute)
    let giftController = GiftController()
    
    router.get(uris.gifts, use: giftController.index)
    router.post(uris.gifts, use: giftController.create)
    router.delete(uris.gifts, Gift.parameter, use: giftController.delete)
}
