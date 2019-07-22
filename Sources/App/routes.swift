
import Vapor
import Crypto
import Guardian

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let uris = URIs()
    
    //Controllers
    let giftController = GiftController()
    let imageController = ImageController()
    let giftAdminController = GiftAdminController()
    let giftDonationController = GiftDonationController()
    let categoryController = CategoryController()
    let locationController = LocationController()
    let userController = UserController()
    let userProfileController = UserProfileController()
    let userAdminController = UserAdminController()
    let giftRequestController = GiftRequestController()
    let chatRestfulController = ChatRestfulController()
    let chatBlockController = ChatBlockController()
    let pushNotificationController = PushNotificationController()
    let charityController = CharityController()
    let charityAdminController = CharityAdminController()
    
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
    
    //Routes User Profile
    tokenProtected.get(uris.profile,User.parameter, use: userProfileController.show)
    tokenProtected.post(uris.profile,use: userProfileController.update)
    
    
    //Routes Gifts
    router.post(uris.gifts,use: giftController.index)
    
    tokenProtected.post(uris.gifts_register,use: giftController.create)
    tokenProtected.put(uris.gifts,Gift.parameter, use: giftController.update)
    tokenProtected.delete(uris.gifts,Gift.parameter, use: giftController.delete)
    
    tokenProtected.post(uris.image_upload, use: imageController.uploadImage)
    
    tokenProtected.post(uris.gifts_userRegistered, User.parameter, use: giftController.registeredGifts)
    
    tokenProtected.post(uris.gifts_userDonated, User.parameter, use: giftDonationController.donatedGifts)
    tokenProtected.post(uris.gifts_userReceived, User.parameter, use: giftDonationController.receivedGifts)
    tokenProtected.post(uris.gifts_todonate, User.parameter, use: giftDonationController.giftsToDonate)
    tokenProtected.post(uris.donate, use: giftDonationController.donate)
    
    //Routes Gift Request
    tokenProtected.get(uris.gifts_request,Gift.parameter, use: giftRequestController.requestGift)
    
    //Routes Chat
    tokenProtected.get(uris.chat_contacts, use: chatRestfulController.fetchContacts)
    tokenProtected.post(uris.chat_messages, use: chatRestfulController.fetchMessages)
    tokenProtected.post(uris.chat_send, use: chatRestfulController.sendMessage)
    tokenProtected.post(uris.chat_ack, use: chatRestfulController.ackMessage)
    
    //Routes Chat Block
    tokenProtected.get(uris.chat_contacts_block, use: chatRestfulController.fetchBlockedContacts)
    tokenProtected.put(uris.chat_block, Chat.parameter, use: chatBlockController.blockUser)
    tokenProtected.put(uris.chat_unblock, Chat.parameter, use: chatBlockController.unblockUser)
    
    
    //Routes Admin
    adminProtected.put(uris.gifts_accept,Gift.parameter, use: giftAdminController.acceptGift)
    adminProtected.delete(uris.gifts_reject,Gift.parameter, use: giftAdminController.rejectGift)
    adminProtected.post(uris.gifts_review, use: giftAdminController.unreviewedGifts)
    adminProtected.put(uris.users_allowAccess, use: userAdminController.userAllowAccess)
    adminProtected.delete(uris.users_denyAccess,User.parameter, use: userAdminController.userDenyAccess)
    
    //Routes Charity
    tokenProtected.get(uris.charity_info, User.parameter, use: charityController.getCharityInfo)
    tokenProtected.get(uris.charity_list, use: charityController.getCharityList)
    
    tokenProtected.get(uris.charity_info, use: charityController.show)
    tokenProtected.post(uris.charity_info, use: charityController.create)
    tokenProtected.put(uris.charity_info, use: charityController.update)
    tokenProtected.delete(uris.charity_info, use: charityController.delete)
    
    //Routes Charity Admin
    adminProtected.get(uris.charity_review, use: charityAdminController.getUnreviewedList)
    adminProtected.put(uris.charity_accept, User.parameter, use: charityAdminController.acceptCharity)
    adminProtected.put(uris.charity_reject, User.parameter, use: charityAdminController.rejectCharity)
    
    //Routes Categories
    router.get(uris.categories, use: categoryController.index)
    router.get(uris.province, use: locationController.getProvinces)
    router.get(uris.city, Province.parameter, use: locationController.getCities)
    
    //Routes Push Notification
    tokenProtected.post(uris.push_register, use: pushNotificationController.registerPush)
    adminProtected.post(uris.sendPush, use: pushNotificationController.sendPush)
    
    
}

