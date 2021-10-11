//
//  MainViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

class MainViewController: UITabBarController {

    // MARK: - Constants
    private let backBarButtonItemImageName = "arrow.left"

    private let internalTestingEmailList: Set = [
        "ppyzfbtesting@gmail.com",
        "ppyzdsdafb@gmail.com",
        "charlielaw48@gmail.com",
        "therealchuhan@gmail.com",
        "hanyue.jackie.zhao@gmail.com",
        "ericyoung505@gmail.com",
        "charlie.chang.liu@gmail.com",
        "cw3nm@virginia.edu",
        "hz2ay@virginia.edu",
        "jiaxi.xiong.us@gmail.com",
        "pingpingya@gmail.com",
        "smartpiggylab@gmail.com",
        "themehoapp@gmail.com",
        "ppyzfb@gmail.com",
        "raydeyang@gmail.com",
        "jiaxi.xiong.meho@gmail.com",
        "sjtudyyjk@gmail.com",
    ]

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBadges), name: UIApplication.didBecomeActiveNotification, object: nil)

        // Sets view controllers.
        let newsViewController = NewsViewController.init()
        let expressionViewController = ExpressionViewController.init()
        let conversationViewController = ConversationViewController.init()
        let foundationViewController = FoundationViewController.init()
        let profileViewController = ProfileViewController.init()
        viewControllers = [newsViewController, expressionViewController, conversationViewController, foundationViewController, profileViewController]
        
        // Sets appearance of the tab bar.
        tabBar.barTintColor = .white
        tabBar.tintColor = .wisteriaPurple
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Sets appearance of the navigation bar.
        navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        navigationController?.setNavigationBarHidden(true, animated: false)

        guard let userID = AWSMobileClient.default().userSub else {
            return
        }

        updateTabBadges()
        SharedInfoManager.setCurrentUser(currentUser: userID)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let userDataFetcher = UserDataFetcher.shared
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        userDataFetcher.getUser(userId: userID) { (user, error) in
            if let email = user?.email {
                // Disable Firebase Analytics and enable notification for internal testing accounts.
                if self.internalTestingEmailList.contains(email) {
                    Analytics.setAnalyticsCollectionEnabled(false)
                } else {
                    Analytics.setUserID(userID)
                }
            }
        }
    }

    // MARK: - Internal
    func selectProfileTab() {
        selectedIndex = 4
    }

    func selectTab(at index: MainViewControllerTab) {
        selectedIndex = index.rawValue
    }

    func displayDetailedNewsViewController(newsID: String) {
        let detailedNewsViewController = DetailedNewsViewController.init(newsID: newsID)
        navigationController?.pushViewController(detailedNewsViewController, animated: true)
    }

    func displayDialogModeSelectionViewController(dialogID: String) {
        if let conversationViewController = viewControllers?[2] as? ConversationViewController {
            conversationViewController.displayDialogModeSelectionViewController(dialogID: dialogID)
        }
    }

    @objc
    func updateTabBadges() {
//        guard let userID = AWSMobileClient.default().userSub else {
//            return
//        }
//
//        let tabs: [MainViewControllerTab] = [.stories, .expressions, .talks, .foundations, .profile]
//        for tab in tabs {
//            guard let tabBarItem = tabBar.items?[tab.rawValue] else {
//                continue
//            }
//
//            let notificationBadgeCount = NotificationBadgeManager.notificationBadgeCount(userID: userID, tab: tab)
//            if notificationBadgeCount > 0 {
//                tabBarItem.badgeValue = String(notificationBadgeCount)
//            } else {
//                tabBarItem.badgeValue = nil
//            }
//        }
//
//        let badgeCount = NotificationBadgeManager.appBadgeCount(userID: userID)
//        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
}
