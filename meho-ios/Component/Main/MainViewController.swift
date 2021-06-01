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
        "jiaxi.xiong.meho@gmail.com"
    ]

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let userDataFetcher = UserDataFetcher.shared
        let userID = AWSMobileClient.default().userSub
        guard userID != nil else {
            return
        }
        userDataFetcher.getUser(userId: userID!) { (user, error) in
            if let email = user?.email {
                // Disable Firebase Analytics and enable notification for internal testing accounts.
                if self.internalTestingEmailList.contains(email) {
                    Analytics.setAnalyticsCollectionEnabled(false)

                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                        if granted {
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Internal
    func selectProfileTab() {
        selectedIndex = 4
    }
}
