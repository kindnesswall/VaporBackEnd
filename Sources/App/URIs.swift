//
//  URIs.swift
//  COpenSSL
//
//  Created by Amir Hossein on 1/6/19.
//

import Vapor

class URIs {
    
    private let apiPath: [String]
    
    init() {
        self.apiPath = configuration.main.apiPath
    }
    
    func makeWeb(path: [String]) -> [PathComponent] {
        path.map { .init(stringLiteral: $0) }
    }
    
    func makeAPI(path relativePath: [String]) -> [PathComponent] {
        append(to: apiPath.map { .init(stringLiteral: $0) },
               path: relativePath)
    }
    
    func append(to basePath: [PathComponent],
                path relativePath: [String]) -> [PathComponent] {
        
        var absolutePath = [PathComponent]()
        absolutePath.append(contentsOf: basePath)
        absolutePath.append(
            contentsOf: relativePath.map { .init(stringLiteral: $0) })
        return absolutePath
    }
    
    func appendID(to basePath: [PathComponent]) -> [PathComponent] {
        append(to: basePath, path: [id])
    }
    
    private let id = ":id"
    
    var root: [PathComponent] {
        []
    }
    var home: [PathComponent] {
        makeWeb(path: ["home"])
    }
    var gifts : [PathComponent] {
        makeAPI(path: ["gifts"])
    }
    var gifts_id : [PathComponent] {
        appendID(to: gifts)
    }
    var categories : [PathComponent] {
        makeAPI(path: ["categories"])
    }
    var country : [PathComponent] {
        makeAPI(path: ["countries"])
    }
    var province : [PathComponent] {
        makeAPI(path: ["provinces"])
    }
    var province_id : [PathComponent] {
        appendID(to: province)
    }
    var city : [PathComponent] {
        makeAPI(path: ["cities"])
    }
    var city_id : [PathComponent] {
        appendID(to: city)
    }
    var region: [PathComponent] {
        makeAPI(path: ["regions"])
    }
    var region_id: [PathComponent] {
        appendID(to: region)
    }
    var register : [PathComponent] {
        makeAPI(path: ["register"])
    }
    var login : [PathComponent] {
        makeAPI(path: ["login"])
    }
    var login_firebase : [PathComponent] {
        append(to: login, path: ["firebase"])
    }
    var login_admin_access : [PathComponent] {
        append(to: login, path: ["admin", "access"])
    }
    var register_phoneNumberChange_request : [PathComponent] {
        append(to: register, path: ["phoneNumberChange", "request"])
    }
    var register_phoneNumberChange_validate : [PathComponent] {
        append(to: register, path: ["phoneNumberChange", "validate"])
    }
    var logout : [PathComponent] {
        makeAPI(path: ["logout"])
    }
    var logout_allDevices : [PathComponent] {
        append(to: logout, path: ["allDevices"])
    }
    var logout_oldTokens : [PathComponent] {
        append(to: logout, path: ["oldTokens"])
    }
    var logout_oldTokens_all : [PathComponent] {
        append(to: logout_oldTokens, path: ["all"])
    }
    var logout_oldTokens_admins : [PathComponent] {
        append(to: logout_oldTokens, path: ["admins"])
    }
    var allInvalidDevicePushTokens_forceDelete : [PathComponent] {
        makeAPI(path: ["allInvalidDevicePushTokens", "forceDelete"])
    }
    var chat : [PathComponent] {
        makeAPI(path: ["chat"])
    }
    var chat_start : [PathComponent] {
        append(to: chat, path: ["start"])
    }
    var chat_start_id : [PathComponent] {
        appendID(to: chat_start)
    }
    var chat_contacts : [PathComponent] {
        append(to: chat, path: ["contacts"])
    }
    var chat_contacts_block : [PathComponent] {
        append(to: chat_contacts, path: ["block"])
    }
    var chat_messages : [PathComponent] {
        append(to: chat, path: ["messages"])
    }
    var chat_send : [PathComponent] {
        append(to: chat, path: ["send"])
    }
    var chat_ack : [PathComponent] {
        append(to: chat, path: ["ack"])
    }
    var chat_block : [PathComponent] {
        append(to: chat, path: ["block"])
    }
    var chat_block_id : [PathComponent] {
        appendID(to: chat_block)
    }
    var chat_unblock : [PathComponent] {
        append(to: chat, path: ["unblock"])
    }
    var chat_unblock_id : [PathComponent] {
        appendID(to: chat_unblock)
    }
    var gifts_register : [PathComponent] {
        append(to: gifts, path: ["register"])
    }
    var gifts_userRegistered : [PathComponent] {
        append(to: gifts, path: ["userRegistered"])
    }
    var gifts_userRegistered_id : [PathComponent] {
        appendID(to: gifts_userRegistered)
    }
    var gifts_userDonated: [PathComponent] {
        append(to: gifts, path: ["userDonated"])
    }
    var gifts_userDonated_id: [PathComponent] {
        appendID(to: gifts_userDonated)
    }
    var gifts_userReceived : [PathComponent] {
        append(to: gifts, path: ["userReceived"])
    }
    var gifts_userReceived_id : [PathComponent] {
        appendID(to: gifts_userReceived)
    }
    var gifts_userRequested: [PathComponent] {
        append(to: gifts, path: ["userRequested"])
    }
    var gifts_userRequested_id: [PathComponent] {
        appendID(to: gifts_userRequested)
    }
    var image_upload : [PathComponent] {
        makeAPI(path: ["image", "upload"])
    }
    var gifts_accept : [PathComponent] {
        append(to: gifts, path: ["accept"])
    }
    var gifts_accept_id : [PathComponent] {
        appendID(to: gifts_accept)
    }
    var gifts_reject : [PathComponent] {
        append(to: gifts, path: ["reject"])
    }
    var gifts_reject_id : [PathComponent] {
        appendID(to: gifts_reject)
    }
    var gifts_review : [PathComponent] {
        append(to: gifts, path: ["review"])
    }
    var users : [PathComponent] {
        makeAPI(path: ["users"])
    }
    var users_allowAccess : [PathComponent] {
        append(to: users, path: ["allowAccess"])
    }
    var users_denyAccess : [PathComponent] {
        append(to: users, path: ["denyAccess"])
    }
    var users_denyAccess_id : [PathComponent] {
        appendID(to: users_denyAccess)
    }
    var users_list : [PathComponent] {
        append(to: users, path: ["list"])
    }
    var users_list_active : [PathComponent] {
        append(to: users_list, path: ["active"])
    }
    var users_list_blocked : [PathComponent] {
        append(to: users_list, path: ["blocked"])
    }
    var users_list_chatBlocked : [PathComponent] {
        append(to: users_list, path: ["chatBlocked"])
    }
    var users_statistics : [PathComponent] {
        append(to: users, path: ["statistics"])
    }
    var users_statistics_id : [PathComponent] {
        appendID(to: users_statistics)
    }
    var users_statistics_list : [PathComponent] {
        append(to: users_statistics, path: ["list"])
    }
    var users_statistics_list_active : [PathComponent] {
        append(to: users_statistics_list, path: ["active"])
    }

    var users_statistics_list_blocked : [PathComponent] {
        append(to: users_statistics_list, path: ["blocked"])
    }
    var users_statistics_list_chatBlocked : [PathComponent] {
        append(to: users_statistics_list, path: ["chatBlocked"])
    }
    var charity : [PathComponent] {
        makeAPI(path: ["charity"])
    }
    var charity_list : [PathComponent] {
        append(to: charity, path: ["list"])
    }
    var charity_info_user : [PathComponent] {
        append(to: charity, path: ["info", "user"])
    }
    var charity_info_user_id : [PathComponent] {
        appendID(to: charity_info_user)
    }
    var charity_user : [PathComponent] {
        append(to: charity, path: ["user"])
    }
    var charity_user_id : [PathComponent] {
        appendID(to: charity_user)
    }
    var charity_accept_user : [PathComponent] {
        append(to: charity, path: ["accept", "user"])
    }
    var charity_accept_user_id : [PathComponent] {
        appendID(to: charity_accept_user)
    }
    var charity_reject_user : [PathComponent] {
        append(to: charity, path: ["reject", "user"])
    }
    var charity_reject_user_id : [PathComponent] {
        appendID(to: charity_reject_user)
    }
    var charity_review : [PathComponent] {
        append(to: charity, path: ["review"])
    }
    var charity_list_rejected : [PathComponent] {
        append(to: charity_list, path: ["rejected"])
    }
    var gifts_request : [PathComponent] {
        append(to: gifts, path: ["request"])
    }
    var gifts_request_id : [PathComponent] {
        appendID(to: gifts_request)
    }
    var gifts_status : [PathComponent] {
        append(to: gifts, path: ["status"])
    }
    var gifts_status_id : [PathComponent] {
        appendID(to: gifts_status)
    }
    var gifts_request_status : [PathComponent] {
        append(to: gifts_request, path: ["status"])
    }
    var gifts_request_status_id : [PathComponent] {
        appendID(to: gifts_request_status)
    }
    var gifts_isDelivered: [PathComponent] {
        append(to: gifts, path: ["isDelivered"])
    }
    var gifts_isDelivered_id: [PathComponent] {
        appendID(to: gifts_isDelivered)
    }
    var profile : [PathComponent] {
        makeAPI(path: ["profile"])
    }
    var profile_id : [PathComponent] {
        appendID(to: profile)
    }
    var sendPush : [PathComponent] {
        makeAPI(path: ["sendPush"])
    }
    var push_register : [PathComponent] {
        makeAPI(path: ["push", "register"])
    }
    var statistics : [PathComponent] {
        makeAPI(path: ["statistics"])
    }
    var application : [PathComponent] {
        makeAPI(path: ["application"])
    }
    var application_ios_version : [PathComponent] {
        append(to: application, path: ["ios", "version"])
    }
    var application_android_version : [PathComponent] {
        append(to: application, path: ["android", "version"])
    }
    var sponsors : [PathComponent] {
        makeAPI(path: ["sponsors"])
    }
    var sponsors_id : [PathComponent] {
        appendID(to: sponsors)
    }
    var sponsors_list : [PathComponent] {
        append(to: sponsors, path: ["list"])
    }
    var rating : [PathComponent] {
        makeAPI(path: ["rating"])
    }
    var rating_id : [PathComponent] {
        appendID(to: rating)
    }
    var phone_visibility: [PathComponent] {
        makeAPI(path: ["phone", "visibility"])
    }
    var phone_visibility_setting: [PathComponent] {
        append(to: phone_visibility, path: ["setting"])
    }
    var phone_visibility_setting_id: [PathComponent] {
        appendID(to: phone_visibility_setting)
    }
    var phone_access: [PathComponent] {
        makeAPI(path: ["phone", "access"])
    }
    var phone_access_gift: [PathComponent] {
        append(to: phone_access, path: ["gift"])
    }
    var phone_access_gift_id: [PathComponent] {
        appendID(to: phone_access_gift)
    }
    var report_gift: [PathComponent] {
        append(to: gifts, path: ["report"])
    }
    var report_charity : [PathComponent] {
        append(to: charity, path: ["report"])
    }
    var report_user : [PathComponent] {
        append(to: users, path: ["report"])
    }
    var smsURL: String {
        return "http://rest.ippanel.com/v1/messages/patterns/send"
    }
}
