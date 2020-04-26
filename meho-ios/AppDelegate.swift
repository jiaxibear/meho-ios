//
//  AppDelegate.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Constants
    private let backBarButtonItemImageName = "arrow.left"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Sets appearance of the navigation bar.
        let navigationBarAppearance = UINavigationBarAppearance()
        let backBarButtonItemImage = UIImage.init(systemName: backBarButtonItemImageName)?.withTintColor(.wisteriaPurple).withAlignmentRectInsets(UIEdgeInsets.init(top: 0, left: 0, bottom: 2, right: 0))
        navigationBarAppearance.setBackIndicatorImage(backBarButtonItemImage, transitionMaskImage: backBarButtonItemImage)
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.shadowColor = .white
        let appearance = UINavigationBar.appearance()
        appearance.standardAppearance = navigationBarAppearance
        appearance.scrollEdgeAppearance = navigationBarAppearance
        appearance.tintColor = .wisteriaPurple
        // Override point for customization after application launch.
        AWSMobileClient.default().initialize { (userState, error) in
            print(userState); print(error)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

