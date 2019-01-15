
import Vapor
import Crypto

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
    let categoryController = CategoryController()
    let userController = UserController()
    
    router.get(uris.gifts, use: giftController.index)
    router.get(uris.gifts,Category.parameter, use: giftController.filteredByCategory)
    router.post(uris.gifts, use: giftController.create)
    router.delete(uris.gifts, Gift.parameter, use: giftController.delete)
    
    router.get(uris.categories, use: categoryController.index)
    
    router.post(uris.users, use: userController.createHandler)
}
