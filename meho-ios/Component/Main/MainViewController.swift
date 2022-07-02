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
import AppTrackingTransparency
import FBSDKCoreKit
import EasyTipView
import Instructions

class MainViewController: UITabBarController, UITabBarControllerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate {

    // MARK: - Constants
    private let backBarButtonItemImageName = "arrow.left"
    private let pandaOnboardingContentViewLeadingTrailingMargin = CGFloat(42)

    // MARK: - Data Models
    private var notificationURLString: String?

    private lazy var coachMarksController: CoachMarksController = {
        let coachMarksController = CoachMarksController.init()
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        coachMarksController.overlay.isUserInteractionEnabled = true
        return coachMarksController
    } ()

    private lazy var pandaOnboardingContentView: PandaOnboardingContentView = {
        let width = view.bounds.width - 2 * pandaOnboardingContentViewLeadingTrailingMargin
        let pandaOnboardingContentView = PandaOnboardingContentView.init(title: "Welcome to Meho", subtitle: "I am your Meho Panda!", imageName: "Meho Panda Hi.gif", mainActionString: "🎋 X 4 Meho Onboarding", firstSubActionString: "Tour around each module: Stories, Expressions, Talks, Foundations!", secondSubActionString: "Earn 4 🎋 to feed and play with 🐼!", width: width)
        return pandaOnboardingContentView
    } ()

    // MARK: - Initializers
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(type: NotificationSoftAskType)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(type: NotificationSoftAskType)")
    }

    init(notificationURLString: String? = nil) {
        self.notificationURLString = notificationURLString
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

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

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    Settings.shared.isAdvertiserTrackingEnabled = true
                    Settings.shared.isAutoLogAppEventsEnabled = true
                default:
                    Settings.shared.isAdvertiserTrackingEnabled = false
                    Settings.shared.isAutoLogAppEventsEnabled = false
                }
            }
        }

        if let userID = AWSMobileClient.default().userSub, !PandaOnboardingManager.hasFinishedOnboarding(userID: userID) {
            coachMarksController.start(in: .window(over: self))
        }

        guard let notificationURLString = self.notificationURLString, let notificationURL = URL.init(string: notificationURLString), let host = notificationURL.host else {
            return
        }
        
        Analytics.logEvent("notification_open", parameters: nil)
        
        switch host {
        case "talks":
            self.selectTab(at: .talks)
            let path = notificationURL.path
            let index = path.index(after: path.startIndex)
            let dialogID = String(notificationURL.path.suffix(from: index))
            self.displayDialogModeSelectionViewController(dialogID: dialogID)
        case "expressions":
            self.selectTab(at: .expressions)
        case "stories":
            let path = notificationURL.path
            let index = path.index(after: path.startIndex)
            let newsID = String(notificationURL.path.suffix(from: index))
            if newsID.count > 0 {
                self.displayDetailedNewsViewController(newsID: newsID)
            } else {
                self.selectTab(at: .stories)
            }
        default:
            break
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        if let index = viewControllers?.firstIndex(of: viewController) {
            NotificationBadgeManager.removeNotificationBadgeCount(userID: userID, tab: MainViewControllerTab.init(rawValue: index)!)
        }
        NotificationBadgeManager.removeNotificationBadgeCount(userID: userID, tab: MainViewControllerTab.init(rawValue: selectedIndex)!)
        updateTabBadges()
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
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }

        let tabs: [MainViewControllerTab] = [.stories, .expressions, .talks, .foundations, .profile]
        for tab in tabs {
            guard let tabBarItem = tabBar.items?[tab.rawValue] else {
                continue
            }

            let notificationBadgeCount = NotificationBadgeManager.notificationBadgeCount(userID: userID, tab: tab)
            if notificationBadgeCount > 0 {
                tabBarItem.badgeValue = String(notificationBadgeCount)
            } else {
                tabBarItem.badgeValue = nil
            }
        }
    }

    // MARK: - CoachMarksControllerDataSource
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {

        return coachMarksController.helper.makeCoachMark(for: tabBar)
    }

    func coachMarksController(
        _ coachMarksController: CoachMarksController,
        coachMarkViewsAt index: Int,
        madeFrom coachMark: CoachMark
    ) -> (bodyView: UIView & CoachMarkBodyView, arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
        let arrowView = coachViews.arrowView
        arrowView?.background.innerColor = .wisteriaPurple
        arrowView?.background.borderColor = .clear
        return (bodyView: pandaOnboardingContentView, arrowView: arrowView)
    }

    // MARK: - CoachMarksControllerDelegate
    func coachMarksController(_ coachMarksController: CoachMarksController, didTapCoachMarkAt index: Int) {
        coachMarksController.stop()
    }
}
