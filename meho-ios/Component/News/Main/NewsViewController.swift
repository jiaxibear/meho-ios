//
//  NewsViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TriggerProfileViewDelegate, MehoAnalytics, NewsItemSizeLCollectionViewCellDelegate  {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(15)
    private let newsTabBarItemImageName = "tabbar_news_25pt"

    private let newsCollectionViewCellHeight = CGFloat(110)
    private let newsCollectionViewCellGroupSpacing = CGFloat(20)

    private let horizontalMargin = CGFloat(15)
    private let verticalTopMargin = CGFloat(30)
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

    private var newsCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var newsCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:newsCollectionViewFlowLayout)
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

        didRefresh()
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
        newsCollectionView.refreshControl = refreshControl
        newsCollectionView.dataSource = self
        newsCollectionView.delegate = self
        newsCollectionView.backgroundColor = .white
        newsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        newsCollectionView.showsVerticalScrollIndicator = false
        newsCollectionView.contentInset = .zero

        // collection layout
        newsCollectionViewFlowLayout.scrollDirection = .vertical
        newsCollectionViewFlowLayout.minimumLineSpacing = 30

        newsCollectionView.register(NewsItemSizeXLCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeXLCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeLCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeLCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeSCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeSCellReuseIdentifier)
        newsCollectionView.register(NewsItemSizeXSCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeXSCellReuseIdentifier)
        view.addSubview(newsCollectionView)

        // view constraints
        scrollDownTitleHiddenCollectionViewTopConstraint = newsCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        scrollUpTitleShownCollectionViewTopConstraint = newsCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: verticalTopMargin)
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
            cell.setNews(newsItem)
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
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        let newsItem = newsList[indexPath.item]
        let detailedNewsViewController = DetailedNewsViewController.init(news: newsItem)
        navigationController?.pushViewController(detailedNewsViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let news = newsList[indexPath.item]
        Analytics.logContentImpression(content: news, screenName: screenName)
    }

    // MARK: NewsItemSizeLCollectionViewCellDelegate
    func didTapPlayAudioButton(news: News) {
        let alertController = UIAlertController.init(title: NSLocalizedString("PlayNewsAudioTitile", comment: ""), message: "", preferredStyle: .actionSheet)
        if let audioEnKey = news.audioEnKey {
            let playEnglishAction = UIAlertAction.init(title: NSLocalizedString("PlayEnglishButtonTitle", comment: ""), style: .default) { (action) in

            }
            alertController.addAction(playEnglishAction)
        }
        if let audioZhKey = news.audioZhKey {
            let playChineseAction = UIAlertAction.init(title: NSLocalizedString("PlayChineseButtonTitle", comment: ""), style: .default) { (action) in

            }
            alertController.addAction(playChineseAction)
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("CancelButtonTitle", comment: ""), style: .cancel) { (action) in

        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // rendertype is returned as one of [XS, S, L, XL], usually we respect it. S, L, XL all come with images while XS don't.  If one news is not marked XS but still does not come with image, we should still degrade to XS
    func chooseRenterType(news: News) -> String {
        return news.imageKey == nil ? "XS" : news.renderType
    }

    // implement for the delegate of TitleView when tapping on profile image, navigate to profile view
    func MainTitleViewDidTapProfileImage() {
        let profileController = ProfileViewController.init()
        navigationController?.pushViewController(profileController, animated: true)
    }

    @objc
    func didRefresh() {
        dataFecther.fetchNewsList(count: "50", completionHandler:  { (newsList, error) in
            if (error == nil && newsList != nil) {
                DispatchQueue.main.async {
                    self.newsList = newsList!
                    self.newsCollectionView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        })
    }
}
