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
        self.apiRoute=Constants.apiRoute
    }
    
    var gifts : String {
        return "\(apiRoute)/gifts"
    }
    var categories : String {
        return "\(apiRoute)/categories"
    }
    var province : String {
        return "\(apiRoute)/provinces"
    }
    var city : String {
        return "\(apiRoute)/cities"
    }
    var register : String {
        return "\(apiRoute)/register"
    }
    var login : String {
        return "\(apiRoute)/login"
    }
    var chat : String {
        return "\(apiRoute)/chat"
    }
    var chat_contacts : String {
        return "\(apiRoute)/chat/contacts"
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
    
    var gifts_owner : String {
        return "\(apiRoute)/gifts/owner"
    }
    var gifts_donated: String {
        return "\(apiRoute)/gifts/donated"
    }
    var gifts_received : String {
        return "\(apiRoute)/gifts/received"
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
    
    var gifts_request : String {
        return "\(apiRoute)/gifts/request"
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
    
    func getSMSUrl(apiKey:String,receptor:String,template:String,token:String)->String?{
        let rawUrl = "https://saharsms.com/api/\(apiKey)/json/SendVerify?receptor=\(receptor)&template=\(template)&token=\(token)"
        let encodedURL = rawUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodedURL
    }
}
