//
//  ProfileSetting.swift
//  meho-ios
//
//  Created by Meho Dev on 9/12/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import Foundation

enum ProfileSettingType {
    case account
    case nickname
    case password
    case profiles
    case goal
    case interests
    case professions
    case appVersion
    case contact
    case privacy
    case signOut
    case userAgreement
}

enum ProfileSettingStyle {
    case header
    case item
    case appVersion
}

struct ProfileSetting {
    let title: String
    let subtitle: String?
    let type: ProfileSettingType
    let style: ProfileSettingStyle
}
