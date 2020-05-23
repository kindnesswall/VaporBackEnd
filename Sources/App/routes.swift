
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
    let logoutController = LogoutController()
    let phoneChangeController = PhoneChangeController()
    let userFirebaseController = UserFirebaseController()
    let userProfileController = UserProfileController()
    let userAdminController = UserAdminController()
    let giftRequestController = GiftRequestController()
    let chatRestfulController = ChatRestfulController()
    let chatBlockController = ChatBlockController()
    let pushNotificationController = PushNotificationController()
    let charityController = CharityController()
    let charityAdminController = CharityAdminController()
    let adminStatisticsController = AdminStatisticsController()
    let versionController = ApplicationVersionController()
    
    //Middlewares
    let logMiddleware = LogMiddleware()
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let guardAdminMiddleware = GuardAdminMiddleware()
    let guardianMiddleware = GuardianMiddleware(rate: Rate(limit: 3, interval: .minute),closure:{ _ in
        throw Constants.errors.tryOneMinuteLater
    })
    
    //Groups
    let publicRouter = router.grouped(logMiddleware)
    let tokenProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware, logMiddleware)
    let adminProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware, guardAdminMiddleware, logMiddleware)
    let guardianProtected = router.grouped(guardianMiddleware, logMiddleware)
    let guardianTokenProtected = router.grouped(tokenAuthMiddleware, guardAuthMiddleware, guardianMiddleware, logMiddleware)
    
    
    //Routes Login
    guardianProtected.post(uris.register, use: userController.registerHandler)
    publicRouter.post(uris.login, use: userController.loginHandler)
    adminProtected.post(uris.login_admin_access, use: userController.adminAccessActivationCode)
    guardianTokenProtected.post(uris.register_phoneNumberChange_request, use: phoneChangeController.changePhoneNumberRequest)
    tokenProtected.post(uris.register_phoneNumberChange_validate, use: phoneChangeController.changePhoneNumberValidate)
    tokenProtected.get(uris.logout, use: logoutController.logout)
    tokenProtected.get(uris.logout_allDevices, use: logoutController.logoutAllDevices)
    publicRouter.post(uris.login_firebase, use: userFirebaseController.loginUser)
    
    //Routes User Profile
    tokenProtected.get(uris.profile,User.parameter, use: userProfileController.show)
    tokenProtected.post(uris.profile,use: userProfileController.update)
    
    
    //Routes Gifts
    publicRouter.post(uris.gifts,use: giftController.index)
    
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
    tokenProtected.get(uris.gifts_request_status, Gift.parameter, use: giftRequestController.requestStatus)
    
    //Routes Chat
    tokenProtected.get(uris.chat_start, User.parameter, use: chatRestfulController.startChat)
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
    adminProtected.put(uris.gifts_reject,Gift.parameter, use: giftAdminController.rejectGift)
    adminProtected.post(uris.gifts_review, use: giftAdminController.unreviewedGifts)
    adminProtected.put(uris.users_allowAccess, use: userAdminController.userAllowAccess)
    adminProtected.delete(uris.users_denyAccess,User.parameter, use: userAdminController.userDenyAccess)
    adminProtected.get(uris.users_statistics, User.parameter, use: userAdminController.userStatistics)
    adminProtected.post(uris.users_list_active, use: userAdminController.usersActiveList)
    adminProtected.post(uris.users_list_blocked, use: userAdminController.usersBlockedList)
    adminProtected.get(uris.users_list_chatBlocked, use: userAdminController.usersChatBlockedList)
    
    //Routes Charity
    publicRouter.get(uris.charity_user, User.parameter, use: charityController.getCharityOfUser)
    publicRouter.get(uris.charity_list, use: charityController.getCharityList)
    
    tokenProtected.get(uris.charity_myInfo, use: charityController.show)
    tokenProtected.post(uris.charity_myInfo, use: charityController.create)
    tokenProtected.put(uris.charity_myInfo, use: charityController.update)
    tokenProtected.delete(uris.charity_myInfo, use: charityController.delete)
    
    //Routes Charity Admin
    adminProtected.get(uris.charity_review, use: charityAdminController.getUnreviewedList)
    adminProtected.get(uris.charity_list_rejected, use: charityAdminController.getRejectedList)
    adminProtected.put(uris.charity_accept_user, User.parameter, use: charityAdminController.acceptCharity)
    adminProtected.put(uris.charity_reject_user, User.parameter, use: charityAdminController.rejectCharity)
    
    //Routes Categories
    publicRouter.post(uris.categories, use: categoryController.index)
    publicRouter.get(uris.country, use: locationController.getCountries)
    publicRouter.get(uris.province, Country.parameter, use: locationController.getProvinces)
    publicRouter.get(uris.city, Province.parameter, use: locationController.getCities)
    publicRouter.get(uris.region, City.parameter, use: locationController.getRegions)
    
    //Routes Push Notification
    tokenProtected.post(uris.push_register, use: pushNotificationController.registerPush)
    adminProtected.post(uris.sendPush, use: pushNotificationController.sendPush)
    
    //Statistics
    adminProtected.get(uris.statistics, use: adminStatisticsController.getStatistics)
    
    //Application Version
    tokenProtected.get(uris.application_ios_version, use: versionController.getIOSVersion)
    tokenProtected.get(uris.application_android_version, use: versionController.getAndroidVersion)
    
    adminProtected.post(uris.application_ios_version, use: versionController.setIOSVersion)
    adminProtected.post(uris.application_android_version, use: versionController.setAndroidVersion)
    
}

