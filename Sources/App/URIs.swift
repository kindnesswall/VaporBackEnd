//
//  URIs.swift
//  COpenSSL
//
//  Created by Amir Hossein on 1/6/19.
//

import Foundation

class URIs {
    private let apiRoute:String
    init() {
        self.apiRoute=Constants.appInfo.apiRoute
    }
    
    var gifts : String {
        return "\(apiRoute)/gifts"
    }
    var categories : String {
        return "\(apiRoute)/categories"
    }
    var country : String {
        return "\(apiRoute)/countries"
    }
    var province : String {
        return "\(apiRoute)/provinces"
    }
    var city : String {
        return "\(apiRoute)/cities"
    }
    var region: String {
        return "\(apiRoute)/regions"
    }
    var register : String {
        return "\(apiRoute)/register"
    }
    var login : String {
        return "\(apiRoute)/login"
    }
    var login_firebase : String {
        return "\(apiRoute)/login/firebase"
    }
    var login_admin_access : String {
        return "\(apiRoute)/login/admin/access" 
    }
    var register_phoneNumberChange_request : String {
        return "\(apiRoute)/register/phoneNumberChange/request"
    }
    var register_phoneNumberChange_validate : String {
        return "\(apiRoute)/register/phoneNumberChange/validate"
    }
    var logout : String {
        return "\(apiRoute)/logout"
    }
    var logout_allDevices : String {
        return "\(apiRoute)/logout/allDevices" 
    }
    var chat : String {
        return "\(apiRoute)/chat"
    }
    var chat_start : String {
        return "\(apiRoute)/chat/start"
    }
    var chat_contacts : String {
        return "\(apiRoute)/chat/contacts"
    }
    var chat_contacts_block : String {
        return "\(apiRoute)/chat/contacts/block"
    }
    var chat_messages : String {
        return "\(apiRoute)/chat/messages"
    }
    var chat_send : String {
        return "\(apiRoute)/chat/send"
    }
    var chat_ack : String {
        return "\(apiRoute)/chat/ack"
    }
    var chat_block : String {
        return "\(apiRoute)/chat/block"
    }
    var chat_unblock : String {
        return "\(apiRoute)/chat/unblock"
    }
    
    var gifts_register : String {
        return "\(apiRoute)/gifts/register"
    }
    
    var gifts_userRegistered : String {
        return "\(apiRoute)/gifts/userRegistered"
    }
    var gifts_userDonated: String {
        return "\(apiRoute)/gifts/userDonated"
    }
    var gifts_userReceived : String {
        return "\(apiRoute)/gifts/userReceived"
    }
    var gifts_todonate : String {
        return "\(apiRoute)/gifts/todonate"
    }
    
    var image_upload : String {
        return "\(apiRoute)/image/upload"
    }
    
    var gifts_accept : String {
        return "\(apiRoute)/gifts/accept"
    }
    var gifts_reject : String {
        return "\(apiRoute)/gifts/reject"
    }
    var gifts_review : String {
        return "\(apiRoute)/gifts/review"
    }
    var users_allowAccess : String {
        return "\(apiRoute)/users/allowAccess"
    }
    var users_denyAccess : String {
        return "\(apiRoute)/users/denyAccess"
    }
    var users_list_active : String {
        return "\(apiRoute)/users/list/active"
    }
    var users_list_blocked : String {
        return "\(apiRoute)/users/list/blocked"
    }
    var users_list_chatBlocked : String {
        return "\(apiRoute)/users/list/chatBlocked"
    }
    var users_statistics_list_active : String {
        return "\(apiRoute)/users/statistics/list/active"
    }
    var users_statistics_list_blocked : String {
        return "\(apiRoute)/users/statistics/list/blocked"
    }
    var users_statistics_list_chatBlocked : String {
        return "\(apiRoute)/users/statistics/list/chatBlocked"
    }
    var users_statistics : String {
        return "\(apiRoute)/users/statistics"
    }
    
    var charity_list : String {
        return "\(apiRoute)/charity/list"
    }
    var charity_info_user : String {
        return "\(apiRoute)/charity/info/user"
    }
    var charity_user : String {
        return "\(apiRoute)/charity/user"
    }
    var charity_accept_user : String {
        return "\(apiRoute)/charity/accept/user"
    }
    var charity_reject_user : String {
        return "\(apiRoute)/charity/reject/user"
    }
    var charity_review : String {
        return "\(apiRoute)/charity/review"
    }
    var charity_list_rejected : String {
        return "\(apiRoute)/charity/list/rejected"
    }
    
    var gifts_request : String {
        return "\(apiRoute)/gifts/request"
    }
    var gifts_request_status : String {
        return "\(apiRoute)/gifts/request/status"
    }
    
    var donate : String {
        return "\(apiRoute)/donate"
    }
    var profile : String {
        return "\(apiRoute)/profile"
    }
    var sendPush : String {
        return "\(apiRoute)/sendPush"
    }
    var push_register : String {
        return "\(apiRoute)/push/register"
    }
    var statistics : String {
        return "\(apiRoute)/statistics"
    }
    var application_ios_version : String {
        return "\(apiRoute)/application/ios/version"
    }
    var application_android_version : String {
        return "\(apiRoute)/application/android/version"
    }
    
    var smsURL: String {
        return "http://rest.ippanel.com/v1/messages/patterns/send"
    }
}
