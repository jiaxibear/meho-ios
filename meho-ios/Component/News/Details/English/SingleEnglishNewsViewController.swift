//
//  SingleEnglishNewsViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum EnglishNewsSection: Int {
    case newsChapters
    case relatedNewsList
}

class SingleEnglishNewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MehoAnalytics  {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLableTopMargin = CGFloat(8) // marked as 18 to source subtitle, adjust as no navigationbar border
    private let titleLabelFontSize = CGFloat(24)
    private let chaptersToTitleMargin = CGFloat(18)
    private let relatedNewsListTitle = "You might also like"
    private let sectionVerticalInsets = CGFloat(30)

    // MARK: - Properties
    private let news: News
    private var hasFetchedNewsDetail = false
    private var hasFetchedNewsList = false

    // MARK: - UI
    private let titleLabel = UILabel.init(frame: .zero)
    private var chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    lazy var chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:chaptersCollectionViewFlowLayout)

    private let newsChapterCellReuseIdentifier = "enNewsChapterCell"
    private let newsTitleHeaderCellReuseIdentifier = "enNewsTitleHeader"

    private let newsItemSizeSCellReuseIdentifier = "NewsItemSizeS"
    private let newsItemSizeXSCellReuseIdentifier = "NewsItemSizeXS"

    // MARK: - Datamodels
    private let dataFecther = NewsDataFetcher.init()
    private var newsChapters:[NewsChapter] = []
    private var relatedNewsList:[News] = []
    private var sections:[EnglishNewsSection] = []

    // MARK: MehoAnalytics
    let screenName = "p_meho_stories_english"
    let screenClass = "p_meho_stories_english"

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
        super.init(nibName: nil, bundle: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpChapters()
        
        // Do any additional setup after loading the view.
        // Fetch news chapters
        dataFecther.fetchNewsDetail(newsID: news.identifier, completionHandler: {
            (englishChapters, chineseChapters, recabVocabs, allVocabDict, maybeRelatedArticleIDs, error) in

            if (error == nil && chineseChapters != nil && englishChapters != nil) {
                DispatchQueue.main.async {
                    self.newsChapters = englishChapters!
                    self.tryReloadCollectionView(forSection: .newsChapters)
                    self.hasFetchedNewsDetail = true
                }
            }
            if (error == nil && maybeRelatedArticleIDs != nil) {
                self.dataFecther.fetchRelatedArticleList(relatedArticleIDs: maybeRelatedArticleIDs!) { relatedNewsList, error in
                    if (error == nil && relatedNewsList != nil) {
                        DispatchQueue.main.async {
                            self.relatedNewsList = relatedNewsList!
                            self.tryReloadCollectionView(forSection: .relatedNewsList)
                            self.hasFetchedNewsList = true
                        }
                    }
                }
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    // MARK: - Setup UI
    func setUpChapters() {
        chaptersCollectionView.dataSource = self
        chaptersCollectionView.delegate = self
        chaptersCollectionView.backgroundColor = .white
        chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chaptersCollectionView.contentInset = UIEdgeInsets.init(top: 20, left: trailingLeadingMargin, bottom: 0, right: trailingLeadingMargin)
        // collection layout
        chaptersCollectionViewFlowLayout.scrollDirection = .vertical
        chaptersCollectionViewFlowLayout.minimumLineSpacing = 18
        chaptersCollectionViewFlowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: sectionVerticalInsets, right: 0)

        chaptersCollectionView.register(OneLineTitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newsTitleHeaderCellReuseIdentifier)
        chaptersCollectionView.register(NewsChapterCollectionViewCell.self, forCellWithReuseIdentifier:newsChapterCellReuseIdentifier)
        chaptersCollectionView.register(NewsItemSizeSCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeSCellReuseIdentifier)
        chaptersCollectionView.register(NewsItemSizeXSCollectionViewCell.self, forCellWithReuseIdentifier:newsItemSizeXSCellReuseIdentifier)
        view.addSubview(chaptersCollectionView)

        // view constraints
        chaptersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chaptersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chaptersCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let detailedNewsSections = sections[indexPath.section]
            var sectionTitle = ""
            var sectionDate:String?
            switch detailedNewsSections {
            case .newsChapters:
                sectionTitle = news.title_en
                sectionDate = news.date
                break
            case .relatedNewsList:
                sectionTitle = relatedNewsListTitle
                break
            }
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newsTitleHeaderCellReuseIdentifier, for: indexPath) as? OneLineTitleHeaderCollectionReusableView {
                headerView.setHeader(title: sectionTitle, maybeDate: sectionDate)
                return headerView
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let detailedNewsSections = sections[section]
        var sectionTitle = ""
        var sectionDate = ""
        switch detailedNewsSections {
        case .newsChapters:
            sectionTitle = news.title_en
            sectionDate = news.date
        case .relatedNewsList:
            sectionTitle = relatedNewsListTitle
        }
        return CGSize.init(width: 0, height: OneLineTitleHeaderCollectionReusableView.heightForHeader(with :collectionView.contentSize.width, title: sectionTitle, maybeDate: sectionDate))
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let detailedNewsSections = sections[section]
        switch detailedNewsSections {
        case .newsChapters:
            return newsChapters.count
        case .relatedNewsList:
            return relatedNewsList.count
        }
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailedNewsSections = sections[indexPath.section]
        switch detailedNewsSections {
        case .newsChapters:
            break
        case .relatedNewsList:
            let parameters = [
                MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_stories_related_news-view_story",
                MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_story",
                MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
                MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
            ]
            Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
            
            let relatedNewsItem = relatedNewsList[indexPath.item]
            let detailedNewsViewController = DetailedNewsViewController.init(news: relatedNewsItem)
            navigationController?.pushViewController(detailedNewsViewController, animated: true)
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let detailedNewsSections = sections[indexPath.section]
        let width = collectionView.bounds.width - 2 * trailingLeadingMargin
        switch detailedNewsSections {
        case .newsChapters:
            let chapter = newsChapters[indexPath.item]
            return CGSize(width: width, height: NewsChapterCollectionViewCell.cellHeight(with: width, newsChapter: chapter))
        case .relatedNewsList:
            let relatedNewsItem = relatedNewsList[indexPath.item]
            switch chooseRenterType(news:relatedNewsItem) {
                case "S":
                    return CGSize(width: width, height: NewsItemSizeSCollectionViewCell.cellHeight(with: width, news: relatedNewsItem, showAudio: false))
                case "XS":
                    return CGSize(width: width, height: NewsItemSizeXSCollectionViewCell.cellHeight(with: width, news: relatedNewsItem))
                default:
                    return CGSize(width: width, height: 0)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let detailedNewsSections = sections[indexPath.section]
        switch detailedNewsSections {
        case .newsChapters:
            let chapter = newsChapters[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsChapterCellReuseIdentifier, for: indexPath) as! NewsChapterCollectionViewCell
            cell.newsChapter = chapter
            return cell
        case .relatedNewsList:
            let relatedNewsItem = relatedNewsList[indexPath.item]
            switch chooseRenterType(news:relatedNewsItem) {
                case "S":
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeSCellReuseIdentifier, for: indexPath) as! NewsItemSizeSCollectionViewCell
                    cell.showAudio = false
                    cell.news = relatedNewsItem
                    return cell
                case "XS":
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsItemSizeXSCellReuseIdentifier, for: indexPath) as! NewsItemSizeXSCollectionViewCell
                    cell.setNews(relatedNewsItem)
                    return cell
                default:
                    return UICollectionViewCell.init()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == newsChapters.count - 1 {
            NotificationManager.displayNotificationSoftAsk(type: .stories, from: self)
        }
    }

    // rendertype is returned as one of [XS, S], usually we respect it. S should come with images while XS don't.  If one news is not marked XS but still does not come with image, we should still degrade to XS
    func chooseRenterType(news: News) -> String {
        return news.imageKey == nil ? "XS" : "S"
    }

    func tryReloadCollectionView(forSection: EnglishNewsSection) {
        switch forSection {
        case .newsChapters:
            if (!hasFetchedNewsDetail) {
                sections.insert(.newsChapters, at: 0)
            }
            break
        case .relatedNewsList:
            if (!hasFetchedNewsList) {
                sections.append(.relatedNewsList)
            }
            break
        }
        chaptersCollectionView.reloadData()
    }

}
