//
//  PhoneVisibilitySetting.swift
//  App
//
//  Created by Amir Hossein on 5/5/21.
//

import Vapor
import Fluent

enum PhoneVisibilitySetting: String, Codable {
    case all
    case charity
    case none
}

struct PhoneVisibilitySettingIO: Content {
    let setting: PhoneVisibilitySetting
    
    init(user: User) {
        setting = user.phoneVisibilitySetting
    }
}

extension User {
    var phoneVisibilitySetting: PhoneVisibilitySetting {
        return (isPhoneVisibleForAll ?? false) ? .all : ((isPhoneVisibleForCharities ?? false) ? .charity : .none)
    }
    
    func setPhoneVisibility(setting: PhoneVisibilitySetting, on conn: Database) -> EventLoopFuture<HTTPStatus> {
        switch setting {
        case .all:
            isPhoneVisibleForAll = true
            isPhoneVisibleForCharities = true
        case .charity:
            isPhoneVisibleForAll = false
            isPhoneVisibleForCharities = true
        case .none:
            isPhoneVisibleForAll = false
            isPhoneVisibleForCharities = false
        }
        return update(on: conn)
            .transform(to: .ok)
    }
}
