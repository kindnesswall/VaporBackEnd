
import Vapor
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let uris = URIs()
    
    //Controllers
    let giftController = GiftController()
    let categoryController = CategoryController()
    let userController = UserController()
    
    //Middlewares
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    
    //Groups
    let tokenProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    
    //Routes Login
    router.post(uris.register, use: userController.registerHandler)
    router.post(uris.login, use: userController.loginHandler)
    
    
    //Routes Gifts
    router.post(uris.gifts,use: giftController.index)
    router.post(uris.gifts_categories,Category.parameter, use: giftController.filteredByCategory)
    
    tokenProtected.post(uris.gifts_register,use: giftController.create)
    tokenProtected.delete(uris.gifts,Gift.parameter, use: giftController.delete)
    
    tokenProtected.post(uris.gifts_images, use: giftController.uploadImage)
    
    tokenProtected.post(uris.gifts_owner, use: giftController.filteredByOwner)
    
    //Routes Categories
    router.get(uris.categories, use: categoryController.index)
    
    
}

