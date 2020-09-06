//
//  DetailedNewsViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/4/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

class DetailedNewsViewController: UIViewController {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let newsDetailAndBottomMargin = CGFloat(4)
    private let reservedNewsSourceWidth = 256
    private let reservedNewsSourceHeight = 45
    private let sourceTitleLabelFontSize = CGFloat(18)
    private let sourceSubTitleLabelFontSize = CGFloat(14)
    private let languageToggleLabelFontSize = CGFloat(14)
    private let bottomBarHeight = CGFloat(66)
    private let likeHeartMargin = CGFloat(10)
    private let likeHeartSideLength = CGFloat(50)
    private let newsTabBarItemImageName = "tabbar_news_25pt"
    private let newsSaveUnfilledImageName = "purple_saved_unfilled"
    private let newsSaveFilledImageName = "purple_saved_filled"
    private let newsShareButtonImageName = "stories_share"

    // TODO move to Localizeable.strings
    private let languageToggleEnText = "ENG"
    private let languageToggleZhText = "中"
    private let sourceSubtitle = "Curated By Meho"

    // MARK: - Datamodels
    private let userDataFetcher = UserDataFetcher.init()

    // MARK: - Properties
    private let news: News
    private var isInProgress:Bool?
    private var isCompleted:Bool?

    // MARK: - UI
    // navigation bar
    private let sourceTitleLabel = UILabel.init(frame: .zero)
    private let sourceSubTitleLabel = UILabel.init(frame: .zero)
    private let newsSourceNavigationView = UIView.init(frame: .zero)

    // main news view
    private var singleNewsView: UIView!
    // bottom bar
    private let likeButton = UIButton.init(frame: .zero)
    private let languageToggleButton = UISwitch.init(frame: .zero)
    private let languageToggleEnLabel = UILabel.init(frame: .zero)
    private let languageToggleZhLabel = UILabel.init(frame: .zero)
    private let bottomBarView = UIView.init(frame: .zero)


    // MARK: - Child Controllers
    private let singleEnNewsViewController:SingleEnglishNewsViewController
    private let singleZhNewsViewController:SingleChineseNewsViewController

    // MARK: - Init
    init() {
        fatalError("Use init")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    init(news: News) {
        self.news = news
        singleEnNewsViewController = SingleEnglishNewsViewController.init(news: news)
        singleZhNewsViewController = SingleChineseNewsViewController.init(news: news)
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        /* Navigation bar: custom News source label, news share button on right */
        setUpNavigationBar()
        setupBottomBarView() // this has to come before newsdetailview as newsdetailview has bottom constrain on barview's topanchor
        setUpInitialNewsDetailView()

        guard let userId = AWSMobileClient.default().userSub else { return }
        userDataFetcher.getUserItemSave (userId: userId, itemId: self.news.identifier, completionHandler: { (isSaved, error) in
            if (error == nil && isSaved) {
                DispatchQueue.main.async {
                    self.likeButton.isSelected = true
                }
            }
        })

        checkArticleStatus()
    }

    func setUpNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.titleView = newsSourceNavigationView
        view.backgroundColor = .white
        let newsShareButtonImage = UIImage.init(named: newsShareButtonImageName)
        let newsShareButtonItem = UIBarButtonItem.init(image: newsShareButtonImage, style: .plain, target: self, action: #selector(didTapShareButton))
        navigationItem.setRightBarButton(newsShareButtonItem, animated: true)
        setUpNewsSourceView(newsSource: news.source)
    }

    // MARK: - UI elements setup
    func setUpNewsSourceView(newsSource: String) {
        let newsSourceRect:CGRect = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: reservedNewsSourceWidth, height: reservedNewsSourceHeight))

        newsSourceNavigationView.frame = newsSourceRect
        newsSourceNavigationView.translatesAutoresizingMaskIntoConstraints = false
        newsSourceNavigationView.backgroundColor = .white

        sourceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceTitleLabel.text = newsSource
        sourceTitleLabel.textColor = .darkGrayTwo
        let titlefontDescriptor = UIFont.systemFont(ofSize: sourceTitleLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        sourceTitleLabel.font = UIFont.init(descriptor: titlefontDescriptor!, size: 0)
        newsSourceNavigationView.addSubview(sourceTitleLabel)

        sourceSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceSubTitleLabel.text = sourceSubtitle
        sourceSubTitleLabel.textColor = .darkGrayTwo
        let subTitlefontDescriptor = UIFont.systemFont(ofSize: sourceSubTitleLabelFontSize, weight: .thin).fontDescriptor.withDesign(.rounded)
        sourceSubTitleLabel.font = UIFont.init(descriptor: subTitlefontDescriptor!, size: 0)
        newsSourceNavigationView.addSubview(sourceSubTitleLabel)

        // setup constraint
        newsSourceNavigationView.widthAnchor.constraint(equalToConstant: CGFloat(reservedNewsSourceWidth)).isActive = true
        newsSourceNavigationView.heightAnchor.constraint(equalToConstant: CGFloat(reservedNewsSourceHeight)).isActive = true
        sourceTitleLabel.topAnchor.constraint(equalTo: newsSourceNavigationView.topAnchor).isActive = true
        sourceTitleLabel.centerXAnchor.constraint(equalTo: newsSourceNavigationView.centerXAnchor).isActive = true
        sourceSubTitleLabel.topAnchor.constraint(equalTo: sourceTitleLabel.bottomAnchor).isActive = true
        sourceSubTitleLabel.centerXAnchor.constraint(equalTo: sourceTitleLabel.centerXAnchor).isActive = true

    }

    // setup a view controller placeholder for news details, its content is filled up by different
    func setUpInitialNewsDetailView() {
        addChildNewsController(controllerToAdd: singleEnNewsViewController)
    }

    // setup the bar view for news detail page at the bottom, including like button and language toggle switch
    func setupBottomBarView() {
        // Sets up the bottom bar
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.layer.shadowColor = UIColor.barShadow.cgColor
        bottomBarView.layer.shadowOpacity = 1
        bottomBarView.layer.shadowOffset = .zero
        bottomBarView.layer.shadowRadius = 4
        bottomBarView.layer.masksToBounds = false
        bottomBarView.backgroundColor = .white
        view.addSubview(bottomBarView)

        // Set up the heart
        let newsLikeHeartUnfilledImage = UIImage.init(named: newsSaveUnfilledImageName)
        let newsLikeHeartFilledImag = UIImage.init(named: newsSaveFilledImageName)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(newsLikeHeartUnfilledImage, for: UIControl.State.normal)
        likeButton.setImage(newsLikeHeartFilledImag, for: UIControl.State.selected)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        bottomBarView.addSubview(likeButton)

        // Set up the lanuguage switch
        languageToggleButton.translatesAutoresizingMaskIntoConstraints = false
        languageToggleButton.isOn = false
        languageToggleButton.onTintColor = .wisteriaPurple
        languageToggleButton.tintColor = .wisteriaPurple
        languageToggleButton.thumbTintColor = .white
        languageToggleButton.backgroundColor = .wisteriaPurple
        languageToggleButton.layer.cornerRadius = 16
        languageToggleButton.addTarget(self, action: #selector(didTapLanguageToggleButton), for: .touchUpInside)
        bottomBarView.addSubview(languageToggleButton)

        // Set up the language toggle text
        languageToggleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        languageToggleEnLabel.text = languageToggleEnText
        languageToggleEnLabel.textColor = .wisteriaPurple
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: languageToggleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        languageToggleEnLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        bottomBarView.addSubview(languageToggleEnLabel)
        languageToggleZhLabel.translatesAutoresizingMaskIntoConstraints = false
        languageToggleZhLabel.text = languageToggleZhText
        languageToggleZhLabel.textColor = .wisteriaPurple
        languageToggleZhLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: languageToggleLabelFontSize)
        bottomBarView.addSubview(languageToggleZhLabel)

        bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBarView.heightAnchor.constraint(equalToConstant: bottomBarHeight).isActive = true

        likeButton.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor, constant: likeHeartMargin).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: bottomBarView.bottomAnchor, constant: -likeHeartMargin).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: likeHeartSideLength).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: likeHeartSideLength).isActive = true


        languageToggleZhLabel.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor, constant: -CGFloat(23)).isActive = true
        languageToggleZhLabel.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor, constant: -CGFloat(2)).isActive = true

        languageToggleButton.trailingAnchor.constraint(equalTo: languageToggleZhLabel.leadingAnchor, constant: -CGFloat(3)).isActive = true
        languageToggleButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true

        languageToggleEnLabel.trailingAnchor.constraint(equalTo: languageToggleButton.leadingAnchor, constant: -CGFloat(3)).isActive = true
        languageToggleEnLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true
    }

    // MARK: - Private buttom actions
    @objc
    func didTapLikeButton() {
        guard let userId = AWSMobileClient.default().userSub else { return }
        if self.likeButton.isSelected {
            userDataFetcher.deleteUserItemSave(userId: userId, itemId: self.news.identifier) { (unsaveSuccess, error) in
                if (error == nil && unsaveSuccess) {
                     DispatchQueue.main.async {
                         self.likeButton.isSelected = false
                         self.view.makeToast(NSLocalizedString("removeSuccessfullyMessage", comment: ""))
                     }
                }
            }
        } else {
            userDataFetcher.createUserItemSave(userId: userId, itemId: self.news.identifier, itemType: "ARTICLE") { (saveSuccess, error) in
                if (error == nil && saveSuccess) {
                     DispatchQueue.main.async {
                         self.likeButton.isSelected = true
                         self.view.makeToast(NSLocalizedString("saveSuccessfullyMessage", comment: ""))
                     }
                }
            }
        }
        likeButton.isSelected = !likeButton.isSelected
    }

    @objc
    func didTapShareButton() {
        let newsTitle = "Join me and sign up for Meho to explore great content on China and learn hands-on Chinese skills!"
        let logoImage = UIImage.init(named: "auth_logo")

        if let myWebsite = URL(string: "https://www.wearemeho.com/") {//Enter link to your app here
            let objectsToShare = [newsTitle, logoImage!, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]

            self.present(activityVC, animated: true, completion: nil)
        }
    }

    @objc
    func didTapLanguageToggleButton() {
        var itemID: String
        var itemName: String
        if languageToggleButton.isOn {
            removeChildNewsController(controllerToRemove: singleEnNewsViewController)
            addChildNewsController(controllerToAdd: singleZhNewsViewController)
            itemID = "p_meho_stories_english-toggle_storie_chinese"
            itemName = "toggle_stories_chinese"
        } else {
            removeChildNewsController(controllerToRemove: singleZhNewsViewController)
            addChildNewsController(controllerToAdd: singleEnNewsViewController)
            itemID = "p_meho_stories_chinese-toggle_english"
            itemName = "toggle_stories_english"
        }
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: itemID,
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: itemName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        singleNewsView.translatesAutoresizingMaskIntoConstraints = false
        singleNewsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        singleNewsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        singleNewsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        singleNewsView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor).isActive = true
    }

    func addChildNewsController(controllerToAdd: UIViewController) {
        addChild(controllerToAdd)
        controllerToAdd.didMove(toParent: self)
        singleNewsView = controllerToAdd.view
        singleNewsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(singleNewsView)

        // Sets up layout constrainsts.
        singleNewsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        singleNewsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        singleNewsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        singleNewsView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -newsDetailAndBottomMargin).isActive = true
    }

    func removeChildNewsController(controllerToRemove: UIViewController) {
        singleNewsView.removeFromSuperview()
        controllerToRemove.removeFromParent()
        controllerToRemove.didMove(toParent: nil)
    }

    func checkArticleStatus() {
        guard let userId = AWSMobileClient.default().userSub else { return }
        userDataFetcher.getUserItemInProgress (userId: userId, itemId: self.news.identifier, completionHandler: { (isInProgress, error) in
            if (error == nil && isInProgress) {
                self.isInProgress = true
            } else {
                self.isInProgress = false
            }
            self.startArticleProgressIfNeeded(userId: userId)
        })
        userDataFetcher.getUserItemCompleted (userId: userId, itemId: self.news.identifier, completionHandler: { (isCompleted, error) in
            if (error == nil && isCompleted) {
                self.isCompleted = true
            } else {
                self.isCompleted = false
            }
            self.startArticleProgressIfNeeded(userId: userId)
        })

    }

    func startArticleProgressIfNeeded(userId:String) {
        if let articleIsInProgress = self.isInProgress, let articleIsCompleted = self.isCompleted {
            if !articleIsInProgress && !articleIsCompleted {
                userDataFetcher.createUserItemInProgress(userId: userId, itemId: self.news.identifier, itemType: "ARTICLE") { (createInProgressSuccess, error) in
                    if (error == nil && createInProgressSuccess) {
                        // do nothing
                        print("user:" + userId + ",article:" + self.news.identifier + " - added inprogress successful")
                    } else {
                        print("user:" + userId + ",article:" + self.news.identifier + " - added inprogress failed")
                    }
                }
            } else {
                var status = "not started"
                if articleIsInProgress {
                    status = "in progress"
                } else if articleIsCompleted{
                    status = "completed"
                }
                print("user:" + userId + ",article:" + self.news.identifier + ", status:" + status)
            }
        } else{
            print("user:" + userId + ",article:" + self.news.identifier + " - not all status fetched yet, do nothing")
        }
    }
}
