
import Vapor
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let uris = URIs(apiRoute: Constants.apiRoute)
    
    //Controllers
    let giftController = GiftController()
    let categoryController = CategoryController()
    let userController = UserController()
    
    //Middlewares
    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    
    //Groups
    let basicProtected = router.grouped(basicAuthMiddleware, guardAuthMiddleware)
    let tokenProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    
    //Routes Login
    router.post(uris.register, use: userController.createHandler)
    basicProtected.post(uris.login, use: userController.loginHandler)
    
    
    //Routes Gifts
    router.get(uris.gifts,use: giftController.index)
    router.get(uris.gifts_categories,Category.parameter, use: giftController.filteredByCategory)
    
    router.post(uris.gifts,use: giftController.create)
    router.delete(uris.gifts,Gift.parameter, use: giftController.delete)
    
    //Routes Categories
    router.get(uris.categories, use: categoryController.index)
    
    
}

