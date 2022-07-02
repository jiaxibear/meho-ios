//
//  PandaOnboardingManager.swift
//  meho-ios
//
//  Created by Meho Dev on 7/1/22.
//  Copyright © 2022 Meho. All rights reserved.
//

import UIKit

class PandaOnboardingManager: NSObject {
    private static let hasSeenStoriesTabKey = "hasSeenStoriesTabKey"
    private static let hasSeenExpressionsTabKey = "hasSeenExpressionsTabKey"
    private static let hasSeenTalksTabKey = "hasSeenTalksTabKey"
    private static let hasSeenFoundationsTabKey = "hasSeenFoundationsTabKey"

    class func hasFinishedOnboarding(userID: String) -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: hasSeenStoriesTabKey + userID) && userDefaults.bool(forKey: hasSeenExpressionsTabKey + userID) && userDefaults.bool(forKey: hasSeenTalksTabKey + userID) && userDefaults.bool(forKey: hasSeenFoundationsTabKey + userID)
    }

    class func hasSeenStoriesTab(userID: String) {
        let userDefaults = UserDefaults.standard
        let hasSeenStoriesTabKeyWithUserID = hasSeenStoriesTabKey + userID
        let hasSeenStoriesTab = userDefaults.bool(forKey: hasSeenStoriesTabKeyWithUserID)
        userDefaults.set(true, forKey: hasSeenStoriesTabKeyWithUserID)
        if (!hasSeenStoriesTab) {
            increaseCurrentUserCreditIfNeeded(userID: userID)
        }
    }

    class func hasSeenExpressionsTab(userID: String) {
        let userDefaults = UserDefaults.standard
        let hasSeenExpressionsTabKeyWithUserID = hasSeenExpressionsTabKey + userID
        let hasSeenExpressionsTab = userDefaults.bool(forKey: hasSeenExpressionsTabKeyWithUserID)
        userDefaults.set(true, forKey: hasSeenExpressionsTabKeyWithUserID)
        if (!hasSeenExpressionsTab) {
            increaseCurrentUserCreditIfNeeded(userID: userID)
        }
    }

    class func hasSeenTalksTab(userID: String) {
        let userDefaults = UserDefaults.standard
        let hasSeenTalksTabKeyWithUserID = hasSeenTalksTabKey + userID
        let hasSeenTalksTab = userDefaults.bool(forKey: hasSeenTalksTabKeyWithUserID)
        userDefaults.set(true, forKey: hasSeenTalksTabKeyWithUserID)
        if (!hasSeenTalksTab) {
            increaseCurrentUserCreditIfNeeded(userID: userID)
        }
    }

    class func hasSeenFoundationsTab(userID: String) {
        let userDefaults = UserDefaults.standard
        let hasSeenFoundationsTabKeyWithUserID = hasSeenFoundationsTabKey + userID
        let hasSeenFoundations = userDefaults.bool(forKey: hasSeenFoundationsTabKeyWithUserID)
        userDefaults.set(true, forKey: hasSeenFoundationsTabKeyWithUserID)
        if (!hasSeenFoundations) {
            increaseCurrentUserCreditIfNeeded(userID: userID)
        }
    }

    private class func increaseCurrentUserCreditIfNeeded(userID: String) {
        if (hasFinishedOnboarding(userID: userID)) {
            UserDataFetcher.shared.increaseCurrentUserCredit(creditIncreased: 4) { user, error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}
