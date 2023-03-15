
import Vapor
import Crypto
import Gatekeeper

/// Register your application's routes here.
public func routes(_ app: Application) throws {
    
    let uris = URIs()
    
    //Controllers
    let landing = LandingController()
    let giftController = GiftController()
    let giftsListController = GiftsListController()
    let userRegisteredGifts = UserRegisteredGiftsListController()
    let userReceivedGifts = UserReceivedGiftsListController()
    let userDonatedGifts = UserDonatedGiftsListController()
    let userRequestedGifts = UserRequestedGiftsListController()
    let imageController = ImageController()
    let giftAdminController = GiftAdminController()
    let adminUnreviewedGifts = AdminUnreviewedGiftsListController()
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
    let sponsor = SponsorController()
    let rating = RatingController()
    let userPhone = UserPhoneController()
    let phoneVisibilitySetting = UserPhoneVisibilitySettingController()
    let reportGiftController = ReportGiftController()
    let reportCharityController = ReportCharityController()
    let reportUserController = ReportUserController()

    //Middlewares
    let logMiddleware = LogMiddleware()
    let tokenAuthMiddleware = Token.authenticator()
    let guardAuthMiddleware = User.guardMiddleware()
    let guardAdminMiddleware = GuardAdminMiddleware()
    let guardCharityMiddleware = GuardCharityMiddleware()
    let gatekeeperMiddleware = GatekeeperMiddleware()
    
    //Groups
    let publicRouter = app.grouped(
        logMiddleware)
    let tokenFetched = app.grouped(
        tokenAuthMiddleware,
        logMiddleware)
    let tokenProtected = app.grouped(
        tokenAuthMiddleware,
        guardAuthMiddleware,
        logMiddleware)
    let adminProtected = app.grouped(
        tokenAuthMiddleware,
        guardAuthMiddleware,
        guardAdminMiddleware,
        logMiddleware)
    let charityProtected = app.grouped(
        tokenAuthMiddleware,
        guardAuthMiddleware,
        guardCharityMiddleware,
        logMiddleware)
    let gatekeeperProtected = app.grouped(
        gatekeeperMiddleware,
        logMiddleware)
    let gatekeeperTokenProtected = app.grouped(
        tokenAuthMiddleware,
        guardAuthMiddleware,
        gatekeeperMiddleware,
        logMiddleware)

    tokenProtected.post(uris.report_gift, use: reportGiftController.report)
    tokenProtected.post(uris.report_charity, use: reportCharityController.report)
    tokenProtected.post(uris.report_user, use: reportUserController.report)

    //Home
    publicRouter.get(uris.root, use: landing.redirectHome)
    publicRouter.get(uris.home, use: landing.present)
    
    //Routes Login
    gatekeeperProtected.post(uris.register, use: userController.registerHandler)
    gatekeeperProtected.post(uris.login, use: userController.loginHandler)
    
    gatekeeperTokenProtected.post(uris.register_phoneNumberChange_request, use: phoneChangeController.changePhoneNumberRequest)
    gatekeeperTokenProtected.post(uris.register_phoneNumberChange_validate, use: phoneChangeController.changePhoneNumberValidate)
    
    tokenProtected.get(uris.logout, use: logoutController.logout)
    tokenProtected.get(uris.logout_allDevices, use: logoutController.logoutAllDevices)
    
    publicRouter.post(uris.login_firebase, use: userFirebaseController.loginUser)
    
    if configuration.main.stage == .development {
        adminProtected.post(uris.login_admin_access, use: userController.adminAccessActivationCode)
    }
    
    //Routes User Profile
    tokenFetched.get(uris.profile_id, use: userProfileController.show)
    tokenProtected.get(uris.profile,
                       use: userProfileController.showAuthenticatedUser)
    tokenProtected.post(uris.profile,use: userProfileController.update)
    
    
    //Routes Gifts
    publicRouter.get(uris.gifts, use: giftsListController.index)
    publicRouter.get(uris.gifts_paginate, use: giftsListController.paginatedIndex)
    publicRouter.get(uris.gifts_id, use: giftController.itemAt)
    
    tokenProtected.post(uris.gifts_register,use: giftController.create)
    tokenProtected.put(uris.gifts_id, use: giftController.update)
    tokenProtected.delete(uris.gifts_id, use: giftController.delete)
    
    tokenProtected.on(.POST, uris.image_upload, body: .collect(maxSize: "20mb"), use: imageController.uploadImage)
    
    tokenFetched.get(uris.gifts_userRegistered_id, use: userRegisteredGifts.index)
    tokenFetched.get(uris.gifts_userDonated_id, use: userDonatedGifts.index)
    tokenFetched.get(uris.gifts_userReceived_id, use: userReceivedGifts.index)
    publicRouter.get(uris.gifts_userRequested_id, use: userRequestedGifts.index)
    
    tokenFetched.get(uris.gifts_userRegistered_id_paginate, use: userRegisteredGifts.paginatedIndex)
    tokenFetched.get(uris.gifts_userDonated_id_paginate, use: userDonatedGifts.paginatedIndex)
    tokenFetched.get(uris.gifts_userReceived_id_paginate, use: userReceivedGifts.paginatedIndex)
    publicRouter.get(uris.gifts_userRequested_id_paginate, use: userRequestedGifts.paginatedIndex)
    
    //Routes Gift Request
    charityProtected.put(
        uris.gifts_request_id,
        use: giftRequestController.requestGift)
    charityProtected.put(
        uris.gifts_request_status_id,
        use: giftRequestController.updateRequestStatus)
    publicRouter.get(
        uris.gifts_status_id,
        use: giftRequestController.getGiftStatus)
    charityProtected.put(
        uris.gifts_isDelivered_id,
        use: giftController.isDelivered)
    
    //Routes Admin
    adminProtected.put(uris.gifts_accept_id, use: giftAdminController.acceptGift)
    adminProtected.put(uris.gifts_reject_id, use: giftAdminController.rejectGift)
    adminProtected.get(uris.gifts_review, use: adminUnreviewedGifts.index)
    adminProtected.get(uris.gifts_review_paginate, use: adminUnreviewedGifts.paginatedIndex)
    adminProtected.put(uris.users_allowAccess, use: adminUserList.userAllowAccess)
    adminProtected.delete(uris.users_denyAccess_id, use: adminUserList.userDenyAccess)
    adminProtected.post(uris.users_list_active, use: adminUserList.usersActiveList)
    adminProtected.post(uris.users_list_blocked, use: adminUserList.usersBlockedList)
    adminProtected.get(uris.users_list_chatBlocked, use: adminUserList.usersChatBlockedList)
    adminProtected.get(uris.users_statistics_id, use: userStatistics.userStatistics)
    adminProtected.post(uris.users_statistics_list_active, use: userStatistics.usersActiveList)
    adminProtected.post(uris.users_statistics_list_blocked, use: userStatistics.usersBlockedList)
    adminProtected.get(uris.users_statistics_list_chatBlocked, use: userStatistics.usersChatBlockedList)
    
    //Routes Charity
    publicRouter.get(uris.charity_user_id, use: charityController.getCharityOfUser)
    publicRouter.get(uris.charity_list, use: charityController.getCharityList)
    
    tokenProtected.get(uris.charity_info_user_id, use: charityInfo.show)
    tokenProtected.post(uris.charity_info_user_id, use: charityInfo.create)
    tokenProtected.put(uris.charity_info_user_id, use: charityInfo.update)
    tokenProtected.delete(uris.charity_info_user_id, use: charityInfo.delete)
    
    //Routes Charity Admin
    adminProtected.get(uris.charity_review, use: charityAdminController.getUnreviewedList)
    adminProtected.get(uris.charity_list_rejected, use: charityAdminController.getRejectedList)
    adminProtected.put(uris.charity_accept_user_id, use: charityAdminController.acceptCharity)
    adminProtected.put(uris.charity_reject_user_id, use: charityAdminController.rejectCharity)
    
    //Routes Categories
    publicRouter.post(uris.categories, use: categoryController.index)
    publicRouter.get(uris.country, use: locationController.getCountries)
    publicRouter.get(uris.province_id, use: locationController.getProvinces)
    publicRouter.get(uris.city_id, use: locationController.getCities)
    publicRouter.get(uris.region_id, use: locationController.getRegions)
    
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
    
    //Sponsor
    publicRouter.get(uris.sponsors_list, use: sponsor.index)
    
    adminProtected.post(uris.sponsors, use: sponsor.create)
    adminProtected.put(uris.sponsors_id, use: sponsor.update)
    adminProtected.delete(uris.sponsors_id, use: sponsor.delete)
    
    //Rating
    tokenProtected.post(uris.rating, use: rating.create)
    tokenProtected.put(uris.rating, use: rating.update)
    tokenFetched.get(uris.rating_id, use: rating.get)
    
    //Phone number of a gift
    tokenProtected.get(uris.phone_access_gift_id, use: userPhone.getPhoneNumberOfAGift)
    
    adminProtected.delete(uris.logout_oldTokens_all, use: logoutController.logoutAllOldTokens)
    adminProtected.delete(uris.logout_oldTokens_admins, use: logoutController.logoutAdminsOldTokens)
    adminProtected.delete(uris.allInvalidDevicePushTokens_forceDelete, use: logoutController.forceDeleteAllDevicePushTokensOfSoftDeletedTokens)
    
    //Phone Visibility Setting
    //These routes are no longer useful
//    publicRouter.get(uris.phone_visibility_setting_id, use: phoneVisibilitySetting.getUserSetting)
//    tokenProtected.get(uris.phone_visibility_setting, use: phoneVisibilitySetting.getOwnerSetting)
//    tokenProtected.post(uris.phone_visibility_setting, use: phoneVisibilitySetting.set)
}

