//
//  MainViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    // MARK: - Constants
    private let backBarButtonItemImageName = "arrow.left"

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets view controllers.
        let newsViewController = NewsViewController.init()
        let expressionViewController = ExpressionViewController.init()
        let conversationViewController = ConversationViewController.init()
        let foundationViewController = FoundationViewController.init()
        viewControllers = [newsViewController, expressionViewController, conversationViewController, foundationViewController]
        
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
}
