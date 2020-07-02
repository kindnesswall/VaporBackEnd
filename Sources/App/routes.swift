
import Vapor
import Crypto
import Guardian

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let uris = URIs()
    
    //Controllers
    let giftController = GiftController()
    let userGifts = UserGiftsController()
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
    let userStatistics = UserStatisticsController()
    let adminUserList = AdminUserListController()
    let giftRequestController = GiftRequestController()
    let chatRestfulController = ChatRestfulController()
    let chatBlockController = ChatBlockController()
    let pushNotificationController = PushNotificationController()
    let charityController = CharityController()
    let charityInfo = CharityInfoController()
    let charityAdminController = CharityAdminController()
    let adminStatisticsController = AdminStatisticsController()
    let versionController = ApplicationVersionController()
    
    //Middlewares
    let logMiddleware = LogMiddleware()
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let guardAdminMiddleware = GuardAdminMiddleware()
    let guardianMiddleware = GuardianMiddleware(rate: Rate(limit: 3, interval: .minute),closure:{ _ in
        throw Abort(.tryOneMinuteLater)
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
    publicRouter.get(uris.gifts, Int.parameter, use: giftController.itemAt)
    
    tokenProtected.post(uris.gifts_register,use: giftController.create)
    tokenProtected.put(uris.gifts, Int.parameter, use: giftController.update)
    tokenProtected.delete(uris.gifts,Gift.parameter, use: giftController.delete)
    
    tokenProtected.post(uris.image_upload, use: imageController.uploadImage)
    
    tokenProtected.post(uris.gifts_userRegistered, Int.parameter, use: userGifts.registeredGifts)
    tokenProtected.post(uris.gifts_userDonated, Int.parameter, use: userGifts.donatedGifts)
    tokenProtected.post(uris.gifts_userReceived, Int.parameter, use: userGifts.receivedGifts)
    
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
    tokenProtected.put(uris.chat_block, Int.parameter, use: chatBlockController.blockUser)
    tokenProtected.put(uris.chat_unblock, Int.parameter, use: chatBlockController.unblockUser)
    
    
    //Routes Admin
    adminProtected.put(uris.gifts_accept,Gift.parameter, use: giftAdminController.acceptGift)
    adminProtected.put(uris.gifts_reject,Gift.parameter, use: giftAdminController.rejectGift)
    adminProtected.post(uris.gifts_review, use: giftAdminController.unreviewedGifts)
    adminProtected.put(uris.users_allowAccess, use: adminUserList.userAllowAccess)
    adminProtected.delete(uris.users_denyAccess,User.parameter, use: adminUserList.userDenyAccess)
    adminProtected.post(uris.users_list_active, use: adminUserList.usersActiveList)
    adminProtected.post(uris.users_list_blocked, use: adminUserList.usersBlockedList)
    adminProtected.get(uris.users_statistics, User.parameter, use: userStatistics.userStatistics)
    adminProtected.post(uris.users_statistics_list_active, use: userStatistics.usersActiveList)
    adminProtected.post(uris.users_statistics_list_blocked, use: userStatistics.usersBlockedList)
    adminProtected.get(uris.users_statistics_list_chatBlocked, use: userStatistics.usersChatBlockedList)
    
    //Routes Charity
    publicRouter.get(uris.charity_user, Int.parameter, use: charityController.getCharityOfUser)
    publicRouter.get(uris.charity_list, use: charityController.getCharityList)
    
    tokenProtected.get(uris.charity_info_user, Int.parameter, use: charityInfo.show)
    tokenProtected.post(uris.charity_info_user, Int.parameter, use: charityInfo.create)
    tokenProtected.put(uris.charity_info_user, Int.parameter, use: charityInfo.update)
    tokenProtected.delete(uris.charity_info_user, Int.parameter, use: charityInfo.delete)
    
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
    publicRouter.get(uris.application_ios_version, use: versionController.getIOSVersion)
    publicRouter.get(uris.application_android_version, use: versionController.getAndroidVersion)
    
    adminProtected.post(uris.application_ios_version, use: versionController.setIOSVersion)
    adminProtected.post(uris.application_android_version, use: versionController.setAndroidVersion)
    
}

