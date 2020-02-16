//
//  MainViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets view controllers.
        let newsViewController = NewsViewController.init()
        let conversationViewController = ConversationViewController.init()
        let foundationViewController = FoundationViewController.init()
        let profileViewController = ProfileViewController.init()
        self.viewControllers = [newsViewController, conversationViewController, foundationViewController, profileViewController]
        
        // Sets appearance of the tab bar.
        self.tabBar.barTintColor = .white
    }

}
