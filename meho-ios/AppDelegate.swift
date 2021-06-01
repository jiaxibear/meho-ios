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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    var appSyncClient: AWSAppSyncClient?

    // MARK: - Constants
    private let backBarButtonItemImageName = "arrow.left"
    private let navigationBarTitleFontSize = CGFloat(18)

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

    func setupAppSyncClient() {
        do {
            let config = try AWSAppSyncClientConfiguration(appSyncServiceConfig: AWSAppSyncServiceConfig())
            appSyncClient = try AWSAppSyncClient(appSyncConfig: config)
        } catch {
            print(error.localizedDescription)
        }
    }
}

