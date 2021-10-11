//
//  SharedInfoManager.swift
//  meho-ios
//
//  Created by Meho Dev on 9/26/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

class SharedInfoManager: NSObject {
    static let currentUserKey = "currentUserKey"

    class func setCurrentUser(currentUser: String) {
        guard let userDefaults = UserDefaults.init(suiteName: "group.com.meho.mehoapp") else {
            return
        }
        userDefaults.set(currentUser, forKey: currentUserKey)
    }

    class func currentUser() -> String? {
        guard let userDefaults = UserDefaults.init(suiteName: "group.com.meho.mehoapp") else {
            return nil
        }
        return userDefaults.string(forKey: currentUserKey)
    }
}
