//
//  NotificationBadgeManager.swift
//  meho-ios
//
//  Created by Meho Dev on 9/26/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

class NotificationBadgeManager: NSObject {

    private static let notificationBadgeCountKeyFormat = "notificationBadgeCountKey-%@-%d"

    class func notificationBadgeCount(userID: String, tab: MainViewControllerTab) -> Int {
        guard let userDefaults = UserDefaults.init(suiteName: "group.com.meho.mehoapp") else {
            return 0
        }

        let notificationBadgeCountKey = String.init(format: notificationBadgeCountKeyFormat, userID, tab.rawValue)
        return userDefaults.integer(forKey: notificationBadgeCountKey)
    }

    class func increaseNotificationBadgeCount(userID: String, tab: MainViewControllerTab) {
        guard let userDefaults = UserDefaults.init(suiteName: "group.com.meho.mehoapp") else {
            return
        }

        let notificationBadgeCountKey = String.init(format: notificationBadgeCountKeyFormat, userID, tab.rawValue)
        let notificationBadgeCount = userDefaults.integer(forKey: notificationBadgeCountKey) + 1
        userDefaults.set(notificationBadgeCount, forKey: notificationBadgeCountKey)
        let badgeCount = NotificationBadgeManager.appBadgeCount(userID: userID)
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }

    class func removeNotificationBadgeCount(userID: String, tab: MainViewControllerTab) {
        guard let userDefaults = UserDefaults.init(suiteName: "group.com.meho.mehoapp") else {
            return
        }

        let notificationBadgeCountKey = String.init(format: notificationBadgeCountKeyFormat, userID, tab.rawValue)
        userDefaults.removeObject(forKey: notificationBadgeCountKey)
        let badgeCount = NotificationBadgeManager.appBadgeCount(userID: userID)
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }

    class func appBadgeCount(userID: String) -> Int {
        guard let userDefaults = UserDefaults.init(suiteName: "group.com.meho.mehoapp") else {
            return 0
        }

        var count = 0
        let tabs: [MainViewControllerTab] = [.stories, .talks, .expressions, .foundations, .profile]
        for tab in tabs {
            let notificationBadgeCountKey = String.init(format: notificationBadgeCountKeyFormat, userID, tab.rawValue)
            count += userDefaults.integer(forKey: notificationBadgeCountKey)
        }
        return count
    }

    class func removeAllNotificationBadgeCount(userID: String) {
        guard let userDefaults = UserDefaults.init(suiteName: "group.com.meho.mehoapp") else {
            return
        }

        let tabs: [MainViewControllerTab] = [.stories, .talks, .expressions, .foundations, .profile]
        for tab in tabs {
            let notificationBadgeCountKey = String.init(format: notificationBadgeCountKeyFormat, userID, tab.rawValue)
            userDefaults.removeObject(forKey: notificationBadgeCountKey)
        }
        let badgeCount = NotificationBadgeManager.appBadgeCount(userID: userID)
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
}
