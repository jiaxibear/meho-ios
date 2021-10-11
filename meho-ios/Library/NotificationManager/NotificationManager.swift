//
//  NotificationManager.swift
//  meho-ios
//
//  Created by Meho Dev on 7/11/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class NotificationManager: NSObject {

    private static let hasEnabledNotificationKeyFormat = "hasEnabledNotificationKey-%@"
    private static let lastAskNotificationDateKeyFormat = "lastAskNotificationDateKey-%@-%d"
    private static let numberOfNotificationAsksKeyFormat = "numberOfNotificationAsksKey-%@-%d"
    private static let maxNumberOfNotificationAsks = 3

    class func displayNotificationSoftAsk(type: NotificationSoftAskType, from viewController: UIViewController) {
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        let userDefaults = UserDefaults.init()
        let hasEnabledNotificationKey = String.init(format: hasEnabledNotificationKeyFormat, userID)
        if userDefaults.bool(forKey: hasEnabledNotificationKey) {
            return
        }

        let numberOfNotificationAsksKey = String.init(format: lastAskNotificationDateKeyFormat, userID, type.rawValue)
        let numberOfNotificationAsks = userDefaults.integer(forKey: numberOfNotificationAsksKey)
        if numberOfNotificationAsks >= maxNumberOfNotificationAsks {
            return
        }

        let lastAskNotificationDateKey = String.init(format: numberOfNotificationAsksKeyFormat, userID, type.rawValue)
        if let lastAskNotificationDate = userDefaults.object(forKey: lastAskNotificationDateKey) as? Date {
            var twoWeeks = DateComponents.init()
            twoWeeks.day = 14
            if let eligibleDate = NSCalendar.current.date(byAdding: twoWeeks, to: lastAskNotificationDate), eligibleDate > Date.init() {
                return
            }
         }

        let notificationSoftAskViewController = NotificationSoftAskViewController.init(type: type)
        let dialogViewController = DialogViewController.init(contentViewController: notificationSoftAskViewController)
        dialogViewController.modalPresentationStyle = .overFullScreen
        dialogViewController.modalTransitionStyle = .crossDissolve
        viewController.present(dialogViewController, animated: true, completion: nil)
        userDefaults.set(numberOfNotificationAsks + 1, forKey: numberOfNotificationAsksKey)
    }

    class func recordUserEnablementState(enabled: Bool, type: NotificationSoftAskType) {
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        let userDefaults = UserDefaults.init()
        let hasEnabledNotificationKey = String.init(format: hasEnabledNotificationKeyFormat, userID)
        if enabled {
            userDefaults.set(true, forKey: hasEnabledNotificationKey)
        } else {
            userDefaults.set(false, forKey: hasEnabledNotificationKey)
            let lastAskNotificationDateKey = String.init(format: numberOfNotificationAsksKeyFormat, type.rawValue)
            userDefaults.set(Date.init(), forKey: lastAskNotificationDateKey)
        }
    }

    class func removeUserStates(userID: String) {
        let userDefaults = UserDefaults.init()
        let hasEnabledNotificationKey = String.init(format: hasEnabledNotificationKeyFormat, userID)
        userDefaults.removeObject(forKey: hasEnabledNotificationKey)
        let types: [NotificationSoftAskType] = [.stories, .talks, .trendingPhrases]
        for type in types {
            let numberOfNotificationAsksKey = String.init(format: lastAskNotificationDateKeyFormat, userID, type.rawValue)
            userDefaults.removeObject(forKey: numberOfNotificationAsksKey)
            let lastAskNotificationDateKey = String.init(format: numberOfNotificationAsksKeyFormat, userID, type.rawValue)
            userDefaults.removeObject(forKey: lastAskNotificationDateKey)
        }
        NotificationBadgeManager.removeAllNotificationBadgeCount(userID: userID)
    }


    class func isNotificationEnabled(userID: String) -> Bool {
        let userDefaults = UserDefaults.init()
        let hasEnabledNotificationKey = String.init(format: hasEnabledNotificationKeyFormat, userID)
        return userDefaults.bool(forKey: hasEnabledNotificationKey)
    }
}
