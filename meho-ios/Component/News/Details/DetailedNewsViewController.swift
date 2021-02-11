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
import Amplify

class DetailedNewsViewController: UIViewController, NewsPlayingNow, NewsPlayingNowViewDelegate {

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
    private let playButtonWidth = CGFloat(44)
    private let playButtonHeight = CGFloat(44)
    private let newsTabBarItemImageName = "tabbar_news_25pt"
    private let newsSaveUnfilledImageName = "purple_saved_unfilled"
    private let newsSaveFilledImageName = "purple_saved_filled"
    private let newsShareButtonImageName = "stories_share"

    // TODO move to Localizeable.strings
    private let languageToggleEnText = "ENG"
    private let languageToggleZhText = "中"
    private let sourceSubtitle = "Curated By Meho"

    // MARK: - Datamodels
    private let userDataFetcher = UserDataFetcher.shared

    // MARK: - Properties
    private let news: News

    // MARK: - UI
    // navigation bar
    private let sourceTitleLabel = UILabel.init(frame: .zero)
    private let sourceSubTitleLabel = UILabel.init(frame: .zero)
    private let newsSourceNavigationView = UIView.init(frame: .zero)

    // main news view
    private var singleNewsView: UIView!

    // bottom bar
    private lazy var likeButton: UIButton = {
        let likeButton = UIButton.init(frame: .zero)
        let newsLikeHeartUnfilledImage = UIImage.init(named: newsSaveUnfilledImageName)
        let newsLikeHeartFilledImag = UIImage.init(named: newsSaveFilledImageName)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(newsLikeHeartUnfilledImage, for: UIControl.State.normal)
        likeButton.setImage(newsLikeHeartFilledImag, for: UIControl.State.selected)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return likeButton
    } ()

    private lazy var languageToggleButton: UISwitch = {
        let languageToggleButton = UISwitch.init(frame: .zero)
        languageToggleButton.translatesAutoresizingMaskIntoConstraints = false
        languageToggleButton.isOn = false
        languageToggleButton.onTintColor = .wisteriaPurple
        languageToggleButton.tintColor = .wisteriaPurple
        languageToggleButton.thumbTintColor = .white
        languageToggleButton.backgroundColor = .wisteriaPurple
        languageToggleButton.layer.cornerRadius = 16
        languageToggleButton.addTarget(self, action: #selector(didTapLanguageToggleButton), for: .touchUpInside)
        return languageToggleButton
    } ()

    private lazy var languageToggleEnLabel: UILabel = {
        let languageToggleEnLabel = UILabel.init(frame: .zero)
        languageToggleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        languageToggleEnLabel.text = languageToggleEnText
        languageToggleEnLabel.textColor = .wisteriaPurple
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: languageToggleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        languageToggleEnLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        return languageToggleEnLabel
    }()

    private lazy var languageToggleZhLabel: UILabel = {
        let languageToggleZhLabel = UILabel.init(frame: .zero)
        languageToggleZhLabel.translatesAutoresizingMaskIntoConstraints = false
        languageToggleZhLabel.text = languageToggleZhText
        languageToggleZhLabel.textColor = .wisteriaPurple
        languageToggleZhLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: languageToggleLabelFontSize)
        return languageToggleZhLabel
    } ()

    private lazy var bottomBarView: UIView = {
        let bottomBarView = UIView.init(frame: .zero)
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.layer.applySketchShadow(color: UIColor.barShadow, alpha: 0.3, x: 0, y: 4, blur: 14, spread: 0)
        bottomBarView.backgroundColor = .white
        return bottomBarView
    } ()

    private lazy var playButton: UIButton = {
        let playButton = UIButton.init(frame: .zero)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        let playButtonDisabledImage = UIImage.init(named: "stories_audio_in_play")
        playButton.setImage(playButtonDisabledImage, for: .disabled)
        let playButtonNormalImage = UIImage.init(named: "stories_purple_headphone_play")
        playButton.setImage(playButtonNormalImage, for: .normal)
        playButton.addTarget(self, action: #selector(didTapPlayAudioButton), for: .touchUpInside)
        return playButton
    } ()

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

    // MARK: - UIViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newsAudioPlayer = NewsAudioPlayer.shared
        if newsAudioPlayer.status != .notStarted, let newsPlayingNowView = newsAudioPlayer.newsPlayingNowView {
            displayNewsPlayingNowView(newsPlayingNowView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation bar: custom News source label, news share button on right
        setUpNavigationBar()
        setupBottomBarView()
        // this has to come before newsdetailview as newsdetailview has bottom constrain on barview's topanchor
        setUpInitialNewsDetailView()
        bottomBarView.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.widthAnchor.constraint(equalToConstant: playButtonWidth),
            playButton.heightAnchor.constraint(equalToConstant: playButtonHeight),
            playButton.centerXAnchor.constraint(equalTo: bottomBarView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor)
        ])
        updatePlayButton()

        guard let userId = AWSMobileClient.default().userSub else { return }
        userDataFetcher.getUserItemSave (userId: userId, itemId: self.news.identifier, completionHandler: { (isSaved, error) in
            if (error == nil && isSaved) {
                DispatchQueue.main.async {
                    self.likeButton.isSelected = true
                }
            }
        })

        userDataFetcher.startItemProgressIfNeeded(userId: userId, itemId: self.news.identifier, itemType: "ARTICLE")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var bottomBarViewBounds = bottomBarView.bounds
        bottomBarViewBounds.size.height = 10
        bottomBarView.layer.shadowPath = UIBezierPath.init(rect: bottomBarViewBounds).cgPath
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
        view.addSubview(bottomBarView)
        bottomBarView.addSubview(likeButton)
        bottomBarView.addSubview(languageToggleButton)
        bottomBarView.addSubview(languageToggleZhLabel)
        bottomBarView.addSubview(languageToggleEnLabel)

        NSLayoutConstraint.activate([
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: bottomBarHeight),

            likeButton.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor, constant: likeHeartMargin),
            likeButton.bottomAnchor.constraint(equalTo: bottomBarView.bottomAnchor, constant: -likeHeartMargin),
            likeButton.heightAnchor.constraint(equalToConstant: likeHeartSideLength),
            likeButton.widthAnchor.constraint(equalToConstant: likeHeartSideLength),

            languageToggleZhLabel.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor, constant: -CGFloat(23)),
            languageToggleZhLabel.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor, constant: -CGFloat(2)),

            languageToggleButton.trailingAnchor.constraint(equalTo: languageToggleZhLabel.leadingAnchor, constant: -CGFloat(3)),
            languageToggleButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),

            languageToggleEnLabel.trailingAnchor.constraint(equalTo: languageToggleButton.leadingAnchor, constant: -CGFloat(3)),
            languageToggleEnLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor)
        ])
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }
        newsPlayingNowView.delegate = self

        view.addSubview(newsPlayingNowView)
        let collectionView = languageToggleButton.isOn ? singleZhNewsViewController.chaptersCollectionView : singleEnNewsViewController.chaptersCollectionView
        var contentInset = collectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        collectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor)
        ])
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        let collectionView = languageToggleButton.isOn ? singleZhNewsViewController.chaptersCollectionView : singleEnNewsViewController.chaptersCollectionView
        var contentInset = collectionView.contentInset
        contentInset.bottom = 0
        collectionView.contentInset = contentInset
        updatePlayButton()
    }

    // MARK: - Private buttom actions
    @objc
    func didTapLikeButton() {
        guard let userId = AWSMobileClient.default().userSub else { return }
        let screenName = languageToggleButton.isOn ? "p_meho_stories_chinese": "p_meho_stories_english"
        if self.likeButton.isSelected {
            Analytics.logContentAction(content: news, screenName: screenName, action: .unBookmark)
            userDataFetcher.deleteUserItemSave(userId: userId, itemId: self.news.identifier) { (unsaveSuccess, error) in
                if (error == nil && unsaveSuccess) {
                     DispatchQueue.main.async {
                         self.likeButton.isSelected = false
                         self.view.makeToast(NSLocalizedString("removeSuccessfullyMessage", comment: ""))
                     }
                }
            }
        } else {
            Analytics.logContentAction(content: news, screenName: screenName, action: .bookmark)
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
        var screenName: String
        if languageToggleButton.isOn {
            removeChildNewsController(controllerToRemove: singleEnNewsViewController)
            addChildNewsController(controllerToAdd: singleZhNewsViewController)
            itemID = "p_meho_stories_english-toggle_storie_chinese"
            itemName = "toggle_stories_chinese"
            screenName = "p_meho_stories_english"
        } else {
            removeChildNewsController(controllerToRemove: singleZhNewsViewController)
            addChildNewsController(controllerToAdd: singleEnNewsViewController)
            itemID = "p_meho_stories_chinese-toggle_english"
            itemName = "toggle_stories_english"
            screenName = "p_meho_stories_chinese"
        }
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: itemID,
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: itemName,
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
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

    private func updatePlayButton() {
        let audioKey = languageToggleButton.isOn ? news.audioZhKey : news.audioEnKey
        if audioKey == nil {
            playButton.isHidden = true
        } else {
            playButton.isHidden = false
            let title = self.languageToggleButton.isOn ? self.news.title_zh : self.news.title_en
            if NewsAudioPlayer.shared.isCurrentlyPlayingAudio(with: title) {
                playButton.isEnabled = false
            } else {
                playButton.isEnabled = true
            }
        }
    }

    @objc
    func didTapPlayAudioButton() {
        let audioKeyOptional = languageToggleButton.isOn ? news.audioZhKey : news.audioEnKey
        guard let audioKey = audioKeyOptional else {
            return
        }

        Amplify.Storage.getURL(key: audioKey.key) { (result) in
            switch result {
            case let .success(audioURL):
                DispatchQueue.main.async {
                    let title = self.languageToggleButton.isOn ? self.news.title_zh : self.news.title_en
                    NewsAudioPlayer.shared.playAudio(audioURL: audioURL, title: title, coverImageKey: self.news.imageKey)
                    if let newsPlayNowView = NewsAudioPlayer.shared.newsPlayingNowView {
                        self.displayNewsPlayingNowView(newsPlayNowView)
                    }
                    self.updatePlayButton()
                }
                break
            case .failure(_):
                break
            }
        }
    }
}
