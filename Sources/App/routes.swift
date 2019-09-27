
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
    let adminStatisticsController = AdminStatisticsController()
    
    //Middlewares
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let guardAdminMiddleware = GuardAdminMiddleware()
    let guardianMiddleware = GuardianMiddleware(rate: Rate(limit: 3, interval: .minute),closure:{ _ in
        throw Constants.errors.tryOneMinuteLater
    })
    
    //Groups
    let tokenProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    let adminProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware, guardAdminMiddleware)
    let guardianProtected = router.grouped(guardianMiddleware)
    let guardianTokenProtected = tokenProtected.grouped(guardianMiddleware)
    
    
    //Routes Login
    guardianProtected.post(uris.register, use: userController.registerHandler)
    router.post(uris.login, use: userController.loginHandler)
    adminProtected.post(uris.login_admin_access, use: userController.adminAccessActivationCode)
    guardianTokenProtected.post(uris.register_phoneNumberChange_request, use: userController.changePhoneNumberRequest)
    tokenProtected.post(uris.register_phoneNumberChange_validate, use: userController.changePhoneNumberValidate)
    tokenProtected.get(uris.logout_allDevices, use: userController.logoutAllDevices)
    
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
    adminProtected.get(uris.users_statistics, User.parameter, use: userAdminController.userStatistics)
    adminProtected.post(uris.users_list_active, use: userAdminController.usersActiveList)
    adminProtected.post(uris.users_list_blocked, use: userAdminController.usersBlockedList)
    adminProtected.get(uris.users_list_chatBlocked, use: userAdminController.usersChatBlockedList)
    
    //Routes Charity
    router.get(uris.charity_user, User.parameter, use: charityController.getCharityOfUser)
    router.get(uris.charity_list, use: charityController.getCharityList)
    
    tokenProtected.get(uris.charity_myInfo, use: charityController.show)
    tokenProtected.post(uris.charity_myInfo, use: charityController.create)
    tokenProtected.put(uris.charity_myInfo, use: charityController.update)
    tokenProtected.delete(uris.charity_myInfo, use: charityController.delete)
    
    //Routes Charity Admin
    adminProtected.get(uris.charity_review, use: charityAdminController.getUnreviewedList)
    adminProtected.put(uris.charity_accept_user, User.parameter, use: charityAdminController.acceptCharity)
    adminProtected.put(uris.charity_reject_user, User.parameter, use: charityAdminController.rejectCharity)
    
    //Routes Categories
    router.get(uris.categories, use: categoryController.index)
    router.get(uris.province, use: locationController.getProvinces)
    router.get(uris.city, Province.parameter, use: locationController.getCities)
    router.get(uris.region, City.parameter, use: locationController.getRegions)
    
    //Routes Push Notification
    tokenProtected.post(uris.push_register, use: pushNotificationController.registerPush)
    adminProtected.post(uris.sendPush, use: pushNotificationController.sendPush)
    
    //Statistics
    adminProtected.get(uris.statistics, use: adminStatisticsController.getStatistics)
    
}

