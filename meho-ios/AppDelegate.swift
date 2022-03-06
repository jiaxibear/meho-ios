//
//  AppDelegate.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAppSync
import Amplify
import AmplifyPlugins
import AVFoundation
import Firebase
import FirebaseAnalytics
import FBSDKCoreKit
import FBSDKCoreKit_Basics
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Properties
    var appSyncClient: AWSAppSyncClient?

    // MARK: - Constants
    private let backBarButtonItemImageName = "arrow.left"
    private let navigationBarTitleFontSize = CGFloat(18)

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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Sets the AV audio session.
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .defaultToSpeaker)
        try? AVAudioSession.sharedInstance().setActive(true)
        // Sets appearance of the navigation bar.
        let navigationBarAppearance = UINavigationBarAppearance()
        let backBarButtonItemImage = UIImage.init(systemName: backBarButtonItemImageName)?.withTintColor(.wisteriaPurple).withAlignmentRectInsets(UIEdgeInsets.init(top: 0, left: 0, bottom: 2, right: 0))
        navigationBarAppearance.setBackIndicatorImage(backBarButtonItemImage, transitionMaskImage: backBarButtonItemImage)
        navigationBarAppearance.configureWithTransparentBackground()
        let fontDescriptor = UIFont.systemFont(ofSize: navigationBarTitleFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        let navigationBarTitleFont = UIFont.init(descriptor: fontDescriptor!, size: 0)
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGrayTwo, NSAttributedString.Key.font: navigationBarTitleFont]
        let appearance = UINavigationBar.appearance()
        appearance.standardAppearance = navigationBarAppearance
        appearance.scrollEdgeAppearance = navigationBarAppearance
        appearance.tintColor = .darkGrayTwo
        // Override point for customization after application launch.
        AWSMobileClient.default().initialize { (userState, error) in
            print(userState ?? "No user state from AWSMobileClient")
            print(error ?? "No error from AWSMobileClient")
        }
        setupAppSyncClient()

        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest2,
           identityPoolId:"us-west-2:c6cfa4af-876b-4eca-802f-da355b63fbe9")

        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)

        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured with auth plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }

        AWSServiceManager.default().defaultServiceConfiguration = configuration

        FirebaseApp.configure()
        let userDataFetcher = UserDataFetcher.shared
        if let userID = AWSMobileClient.default().userSub {
            userDataFetcher.getUser(userId: userID) { (user, error) in
                if let email = user?.email {
                    // Disable Firebase Analytics for internal testing accounts.
                    if self.internalTestingEmailList.contains(email) {
                        Analytics.setAnalyticsCollectionEnabled(false)
                    } else {
                        Analytics.setUserID(userID)
                    }
                }
            }
        }

        let center = UNUserNotificationCenter.current()
        center.delegate = self
        UIApplication.shared.registerForRemoteNotifications()


        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
//        ApplicationDelegate.shared.initializeSDK()
        // Logging Behavior

        return true
    }

    // MARK: UISceneSession Lifecycle



    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }


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

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let tokenID = userID + "_" + deviceID
        let getUserTokenQuery = GetUserTokenQuery.init(id: tokenID)
        appSyncClient?.fetch(query: getUserTokenQuery, resultHandler: { (result, error) in
            let enabled = NotificationManager.isNotificationEnabled(userID: userID)
            if result?.data?.getUserToken != nil {
                let updateUserTokenInput = UpdateUserTokenInput.init(id: tokenID, userId: userID, os: "iOS", token: token, deviceId: deviceID, enable: enabled)
                let updateUserTokenMutation = UpdateUserTokenMutation.init(input: updateUserTokenInput)
                self.appSyncClient?.perform(mutation: updateUserTokenMutation)
            } else if enabled {
                let createUserTokenInput = CreateUserTokenInput.init(id: tokenID, userId: userID, os: "iOS", token: token, deviceId: deviceID, enable: enabled)
                let createUserTokenMutation = CreateUserTokenMutation.init(input: createUserTokenInput)
                self.appSyncClient?.perform(mutation: createUserTokenMutation)
            }
        })
    }

    func setupAppSyncClient() {
        do {
            let config = try AWSAppSyncClientConfiguration(appSyncServiceConfig: AWSAppSyncServiceConfig())
            appSyncClient = try AWSAppSyncClient(appSyncConfig: config)
        } catch {
            print(error.localizedDescription)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let userInfoData = userInfo["data"] as? [AnyHashable: Any], let pinpoint = userInfoData["pinpoint"] as? [AnyHashable: Any], let deepLink = pinpoint["deeplink"] as? String, let deepLinkURL = URL.init(string: deepLink), let host = deepLinkURL.host, let navigationViewController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController, let mainViewController = navigationViewController.viewControllers.first as? MainViewController else {
            completionHandler()
            return
        }

        Analytics.logEvent("notification_open", parameters: nil)
        
        switch host {
        case "talks":
            navigationViewController.popToRootViewController(animated: false)
            mainViewController.selectTab(at: .talks)
            let path = deepLinkURL.path
            let index = path.index(after: path.startIndex)
            let dialogID = String(deepLinkURL.path.suffix(from: index))
            mainViewController.displayDialogModeSelectionViewController(dialogID: dialogID)
        case "expressions":
            navigationViewController.popToRootViewController(animated: false)
            mainViewController.selectTab(at: .expressions)
        case "stories":
            navigationViewController.popToRootViewController(animated: false)
            let path = deepLinkURL.path
            let index = path.index(after: path.startIndex)
            let newsID = String(deepLinkURL.path.suffix(from: index))
            if newsID.count > 0 {
                mainViewController.displayDetailedNewsViewController(newsID: newsID)
            } else {
                mainViewController.selectTab(at: .stories)
            }
        default:
            break
        }
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? [AnyHashable : Any], let contentAvailable = aps["content-available"] as? Int, contentAvailable == 1, let data = userInfo["data"] as? [AnyHashable : Any], let jsonBody = data["jsonBody"] as? [AnyHashable : Any], let tab = jsonBody["tab"] as? String, let userID = AWSMobileClient.default().userSub {
            switch tab {
            case "talks":
                NotificationBadgeManager.increaseNotificationBadgeCount(userID: userID, tab: .talks)
            case "stories":
                NotificationBadgeManager.increaseNotificationBadgeCount(userID: userID, tab: .stories)
            case "expressions":
                NotificationBadgeManager.increaseNotificationBadgeCount(userID: userID, tab: .expressions)
            default:
                break
            }
        }
        completionHandler(.newData)
    }
}

