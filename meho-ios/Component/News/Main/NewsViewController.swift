//
//  NewsViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import Amplify
import Reachability

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TriggerProfileViewDelegate, MehoAnalytics, NewsItemSizeLCollectionViewCellDelegate, NewsItemSizeSCollectionViewCellDelegate, NewsPlayingNow, NewsPlayingNowViewDelegate, LoadingViewDelegate {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(15)
    private let newsTabBarItemImageName = "tabbar_news_25pt"

    private let newsCollectionViewCellHeight = CGFloat(110)
    private let newsCollectionViewCellGroupSpacing = CGFloat(20)

    private let horizontalMargin = CGFloat(15)
    private let verticalTopMargin = CGFloat(30)
    private let collectionTopMargin = CGFloat(24)
    private let newsListTitle = NSLocalizedString("NewsTitle", comment: "")

    // MARK: MehoAnalytics
    let screenName = "p_meho_stories_home"
    let screenClass = "p_meho_stories_home"

    // MARK: UI
    private lazy var titleView: MainTabTitleView = {
        let titleView = MainTabTitleView.init(frame: .zero)
        titleView.setTitleText(text: newsListTitle)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.setDelegate(delegate: self)
        return titleView
    } ()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl.init(frame: .zero)
        refreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        return refreshControl
    } ()

    private lazy var loadingView: LoadingView = {
        let loadingView = LoadingView.init(frame: .zero)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.delegate = self
        return loadingView
    } ()

    private lazy var newsCollectionViewFlowLayout: UICollectionViewFlowLayout  = {
        let newsCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        newsCollectionViewFlowLayout.scrollDirection = .vertical
        newsCollectionViewFlowLayout.minimumLineSpacing = 30
        return newsCollectionViewFlowLayout
    } ()

    private lazy var newsCollectionView: UICollectionView = {
        let newsCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:newsCollectionViewFlowLayout)
        newsCollectionView.refreshControl = refreshControl
        newsCollectionView.dataSource = self
        newsCollectionView.delegate = self
        newsCollectionView.backgroundColor = .white
        newsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        newsCollectionView.showsVerticalScrollIndicator = false
        newsCollectionView.contentInset = .zero
        var contentInset = newsCollectionView.contentInset
        contentInset.bottom = newsCollectionViewCellGroupSpacing
        newsCollectionView.contentInset = contentInset
        newsCollectionView.isHidden = true

        newsCollectionView.register(NewsItemSizeXLCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeXLCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeLCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeLCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeSCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeSCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeXSCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeXSCellReuseIdentifier)
        return newsCollectionView
    } ()

    private var scrollDownTitleHiddenCollectionViewTopConstraint: NSLayoutConstraint!
    private var scrollUpTitleShownCollectionViewTopConstraint: NSLayoutConstraint!

    private let newsItemSizeXLCellReuseIdentifier = "NewsItemSizeXL"
    private let newsItemSizeLCellReuseIdentifier = "NewsItemSizeL"
    private let newsItemSizeSCellReuseIdentifier = "NewsItemSizeS"
    private let newsItemSizeXSCellReuseIdentifier = "NewsItemSizeXS"

    // MARK: - Datamodels
    private let dataFecther = NewsDataFetcher.init()
    private var newsList:[News] = []

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let newsTabBarItemImage = UIImage.init(named: newsTabBarItemImageName)
        let newsTabBarItem = UITabBarItem.init(title: "", image: newsTabBarItemImage, tag: 0)
        tabBarItem = newsTabBarItem
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTitleViewConstraint()
        setupNewsCollectionView()
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: newsCollectionView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: newsCollectionView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: newsCollectionView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: newsCollectionView.trailingAnchor),
        ])
        didRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newsAudioPlayer = NewsAudioPlayer.shared
        if newsAudioPlayer.status != .notStarted, let newsPlayingNowView = newsAudioPlayer.newsPlayingNowView {
            displayNewsPlayingNowView(newsPlayingNowView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
        for index in newsList.indices {
            newsList[index].contentTrackingID = UUID().uuidString
        }
    }

    func setupNewsCollectionView() {
        // Sets up news collection.
        view.addSubview(newsCollectionView)

        // view constraints
        scrollDownTitleHiddenCollectionViewTopConstraint = newsCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        scrollUpTitleShownCollectionViewTopConstraint = newsCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: collectionTopMargin)
        scrollUpTitleShownCollectionViewTopConstraint.isActive = true
        newsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalMargin).isActive = true
        newsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalMargin).isActive = true
        newsCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            titleView.isHidden = true
            scrollUpTitleShownCollectionViewTopConstraint.isActive = false
            scrollDownTitleHiddenCollectionViewTopConstraint.isActive = true
        } else {
            titleView.isHidden = false
            scrollDownTitleHiddenCollectionViewTopConstraint.isActive = false
            scrollUpTitleShownCollectionViewTopConstraint.isActive = true
        }
    }

    private func setupTitleViewConstraint() {
        let margins = view.layoutMarginsGuide
        view.addSubview(titleView)
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalMargin).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalMargin).isActive = true
        titleView.topAnchor.constraint(equalTo: margins.topAnchor, constant: verticalTopMargin).isActive = true
    }


    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsList.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let newsItem = newsList[indexPath.item]
        switch chooseRenterType(news:newsItem) {
        case "XL":
            return CGSize(width: width, height: NewsItemSizeXLCollectionViewCell.cellHeight(with: width, news: newsItem))
        case "L":
            return CGSize(width: width, height: NewsItemSizeLCollectionViewCell.cellHeight(with: width, news: newsItem))
        case "S":
            return CGSize(width: width, height: NewsItemSizeSCollectionViewCell.cellHeight(with: width, news: newsItem))
        case "XS":
            return CGSize(width: width, height: NewsItemSizeXSCollectionViewCell.cellHeight(with: width, news: newsItem))
        default:
            return CGSize(width: width, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let newsItem = newsList[indexPath.item]
        switch chooseRenterType(news:newsItem) {
        case "XL":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeXLCellReuseIdentifier, for: indexPath) as! NewsItemSizeXLCollectionViewCell
            cell.setNews(newsItem)
            return cell
        case "L":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeLCellReuseIdentifier, for: indexPath) as! NewsItemSizeLCollectionViewCell
            cell.news = newsItem
            cell.delegate = self
            return cell
        case "S":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeSCellReuseIdentifier, for: indexPath) as! NewsItemSizeSCollectionViewCell
            cell.news = newsItem
            cell.delegate = self
            return cell
        case "XS":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeXSCellReuseIdentifier, for: indexPath) as! NewsItemSizeXSCollectionViewCell
            cell.setNews(newsItem)
            return cell
        default:
            return UICollectionViewCell.init()
        }
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_stories_home-view_story",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_story",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
            MehoAnalyticsUtils.MehoAnalyticsParameterContentActionCategory: MehoAnalyticsContentAction.view.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        let newsItem = newsList[indexPath.item]
        Analytics.logContentAction(content: newsItem, screenName: screenName, action: .view)
        let detailedNewsViewController = DetailedNewsViewController.init(news: newsItem)
        navigationController?.pushViewController(detailedNewsViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let news = newsList[indexPath.item]
        Analytics.logContentImpression(content: news, screenName: screenName)
    }

    func newsItemSizeSCollectionViewCellDidTapPlayAudioButton(news: News) {
        didTapPlayAudioButton(news: news)
    }

    // MARK: NewsItemSizeLCollectionViewCellDelegate
    func didTapPlayAudioButton(news: News) {
        let alertController = UIAlertController.init(title: NSLocalizedString("PlayNewsAudioTitile", comment: ""), message: "", preferredStyle: .actionSheet)
        if let audioEnKey = news.audioEnKey {
            let playEnglishAction = UIAlertAction.init(title: NSLocalizedString("PlayEnglishButtonTitle", comment: ""), style: .default) { (action) in
                Amplify.Storage.getURL(key: audioEnKey.key) { (result) in
                    switch result {
                    case let .success(audioURL):
                        DispatchQueue.main.async {
                            NewsAudioPlayer.shared.playAudio(audioURL: audioURL, title: news.title_en, coverImageKey: news.imageKey)
                            if let newsPlayNowView = NewsAudioPlayer.shared.newsPlayingNowView {
                                self.displayNewsPlayingNowView(newsPlayNowView)
                            }
                        }
                        break
                    case .failure(_):
                        break
                    }
                }
            }
            alertController.addAction(playEnglishAction)
        }
        if let audioZhKey = news.audioZhKey {
            let playChineseAction = UIAlertAction.init(title: NSLocalizedString("PlayChineseButtonTitle", comment: ""), style: .default) { (action) in
                Amplify.Storage.getURL(key: audioZhKey.key) { (result) in
                    switch result {
                    case let .success(audioURL):
                        DispatchQueue.main.async {
                            NewsAudioPlayer.shared.playAudio(audioURL: audioURL, title: news.title_zh, coverImageKey: news.imageKey)
                            if let newsPlayNowView = NewsAudioPlayer.shared.newsPlayingNowView {
                                self.displayNewsPlayingNowView(newsPlayNowView)
                            }
                        }
                        break
                    case .failure(_):
                        break
                    }
                }
            }
            alertController.addAction(playChineseAction)
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("CancelButtonTitle", comment: ""), style: .cancel) { (action) in

        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - LoadingViewDelegate
    func didTapRetyButton() {
        didRefresh()
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }
        newsPlayingNowView.delegate = self

        view.addSubview(newsPlayingNowView)
        var contentInset = newsCollectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        newsCollectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        var contentInset = newsCollectionView.contentInset
        contentInset.bottom = newsCollectionViewCellGroupSpacing
        newsCollectionView.contentInset = contentInset
    }

    // rendertype is returned as one of [XS, S, L, XL], usually we respect it. S, L, XL all come with images while XS don't.  If one news is not marked XS but still does not come with image, we should still degrade to XS
    func chooseRenterType(news: News) -> String {
        return news.imageKey == nil ? "XS" : news.renderType
    }

    // implement for the delegate of TitleView when tapping on profile image, navigate to profile view
    func mainTitleViewDidTapProfileImage() {
        if let mainViewController = parent as? MainViewController {
            mainViewController.selectProfileTab()
        }
    }

    @objc
    func didRefresh() {
        loadingView.state = .loading
        dataFecther.fetchNewsList(count: "50", completionHandler:  { (newsList, error) in
            if (error == nil && newsList != nil) {
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                    self.newsCollectionView.isHidden = false
                    self.newsList = newsList!
                    self.newsCollectionView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                DispatchQueue.main.async {
                    self.newsCollectionView.isHidden = true
                    let reachability = try! Reachability()
                    if reachability.connection == .unavailable {
                        self.loadingView.state = .noConnection
                    } else {
                        self.loadingView.state = .empty
                    }
                    self.loadingView.isHidden = false
                }
            }
        })
    }
}
