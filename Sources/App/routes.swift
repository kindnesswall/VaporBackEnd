
import Vapor
import Crypto
import Gatekeeper

/// Register your application's routes here.
public func routes(_ app: Application) throws {
    
    let uris = URIs()
    
    //Controllers
    let landing = LandingController()
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
    let sponsor = SponsorController()
    let rating = RatingController()
    let userPhone = UserPhoneController()
    let phoneVisibilitySetting = UserPhoneVisibilitySettingController()
    
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
    
    //Home
    publicRouter.get(uris.root, use: landing.redirectHome)
    publicRouter.get(uris.home, use: landing.present)
    
    //Routes Login
    gatekeeperProtected.post(uris.register, use: userController.registerHandler)
    publicRouter.post(uris.login, use: userController.loginHandler)
    
    gatekeeperProtected.post(uris.register_phoneNumberChange_request, use: phoneChangeController.changePhoneNumberRequest)
    tokenProtected.post(uris.register_phoneNumberChange_validate, use: phoneChangeController.changePhoneNumberValidate)
    
    tokenProtected.get(uris.logout, use: logoutController.logout)
    tokenProtected.get(uris.logout_allDevices, use: logoutController.logoutAllDevices)
    
    publicRouter.post(uris.login_firebase, use: userFirebaseController.loginUser)
    
    if configuration.main.stage == .development {
        adminProtected.post(uris.login_admin_access, use: userController.adminAccessActivationCode)
    }
    
    //Routes User Profile
    tokenFetched.get(uris.profile_id, use: userProfileController.show)
    tokenProtected.post(uris.profile,use: userProfileController.update)
    
    
    //Routes Gifts
    publicRouter.post(uris.gifts,use: giftController.index)
    publicRouter.get(uris.gifts_id, use: giftController.itemAt)
    
    tokenProtected.post(uris.gifts_register,use: giftController.create)
    tokenProtected.put(uris.gifts_id, use: giftController.update)
    tokenProtected.delete(uris.gifts_id, use: giftController.delete)
    
    tokenProtected.post(uris.image_upload, use: imageController.uploadImage)
    
    tokenProtected.post(uris.gifts_userRegistered_id, use: userGifts.registeredGifts)
    tokenProtected.post(uris.gifts_userDonated_id, use: userGifts.donatedGifts)
    tokenProtected.post(uris.gifts_userReceived_id, use: userGifts.receivedGifts)
    
    tokenProtected.post(uris.gifts_todonate_id, use: giftDonationController.giftsToDonate)
    tokenProtected.post(uris.donate, use: giftDonationController.donate)
    
    //Routes Gift Request
    tokenProtected.get(uris.gifts_request_id, use: giftRequestController.requestGift)
    tokenProtected.get(uris.gifts_request_status_id, use: giftRequestController.requestStatus)
    
    //Routes Chat
    tokenProtected.get(uris.chat_start_id, use: chatRestfulController.startChat)
    tokenProtected.get(uris.chat_contacts, use: chatRestfulController.fetchContacts)
    tokenProtected.post(uris.chat_messages, use: chatRestfulController.fetchMessages)
    tokenProtected.post(uris.chat_send, use: chatRestfulController.sendMessage)
    tokenProtected.post(uris.chat_ack, use: chatRestfulController.ackMessage)
    
    //Routes Chat Block
    tokenProtected.get(uris.chat_contacts_block, use: chatRestfulController.fetchBlockedContacts)
    tokenProtected.put(uris.chat_block_id, use: chatBlockController.blockUser)
    tokenProtected.put(uris.chat_unblock_id, use: chatBlockController.unblockUser)
    
    
    //Routes Admin
    adminProtected.put(uris.gifts_accept_id, use: giftAdminController.acceptGift)
    adminProtected.put(uris.gifts_reject_id, use: giftAdminController.rejectGift)
    adminProtected.post(uris.gifts_review, use: giftAdminController.unreviewedGifts)
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
    
    //Phone Visibility Access
    tokenProtected.get(uris.phone_visibility_access_id, use: userPhone.getPhoneNumber)
    
    //Phone Visibility Setting
    publicRouter.get(uris.phone_visibility_setting_id, use: phoneVisibilitySetting.getUserSetting)
    tokenProtected.get(uris.phone_visibility_setting, use: phoneVisibilitySetting.getOwnerSetting)
    tokenProtected.post(uris.phone_visibility_setting, use: phoneVisibilitySetting.set)
}

