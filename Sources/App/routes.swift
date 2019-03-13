
import Vapor
import Crypto
import Guardian

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let uris = URIs()
    
    //Controllers
    let giftController = GiftController()
    let giftImageController = GiftImageController()
    let giftAdminController = GiftAdminController()
    let categoryController = CategoryController()
    let locationController = LocationController()
    let userController = UserController()
    let chatController = ChatController()
    
    //Middlewares
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let guardAdminMiddleware = GuardAdminMiddleware()
    let guardianMiddleware = GuardianMiddleware(rate: Rate(limit: 1, interval: .minute),closure:{ _ in
        throw Constants.errors.tryOneMinuteLater
    })
    
    //Groups
    let tokenProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    let adminProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware, guardAdminMiddleware)
    let guardianProtected = router.grouped(guardianMiddleware)
    
    
    //Routes Login
    guardianProtected.post(uris.register, use: userController.registerHandler)
    router.post(uris.login, use: userController.loginHandler)
    
    
    //Routes Gifts
    router.post(uris.gifts,use: giftController.index)
    
    tokenProtected.post(uris.gifts_register,use: giftController.create)
    tokenProtected.put(uris.gifts,Gift.parameter, use: giftController.update)
    tokenProtected.delete(uris.gifts,Gift.parameter, use: giftController.delete)
    
    tokenProtected.post(uris.gifts_images, use: giftImageController.uploadImage)
    
    tokenProtected.post(uris.gifts_owner, use: giftController.ownerGifts)
    
    //Routes Chat
    tokenProtected.get(uris.chat,User.parameter, use: chatController.getChatId)
    
    //Routes Admin
    adminProtected.put(uris.gifts_accept,Gift.parameter, use: giftAdminController.acceptGift)
    adminProtected.delete(uris.gifts_reject,Gift.parameter, use: giftAdminController.rejectGift)
    adminProtected.post(uris.gifts_review, use: giftAdminController.unreviewedGifts)
    
    //Routes Categories
    router.get(uris.categories, use: categoryController.index)
    router.get(uris.province, use: locationController.getProvinces)
    router.get(uris.city, Province.parameter, use: locationController.getCities)
    
    
}

