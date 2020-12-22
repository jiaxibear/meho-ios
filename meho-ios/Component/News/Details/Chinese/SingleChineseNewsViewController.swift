//
//  SingleChineseNewsViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/6/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

enum ChineseNewsSection: Int {
    case newsChapters
    case recapVocabularyList
}

class SingleChineseNewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NewsChapterCollectionViewCellDelegate, NewsRecapFooterCollectionReusableViewDelegate, MehoAnalytics {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLableTopMargin = CGFloat(8) // marked as 18 to source subtitle, adjust as no navigationbar border
    private let titleLabelFontSize = CGFloat(24)
    private let chaptersToTitleMargin = CGFloat(18)
    private let recapListTitle = "Recap key vocabulary"
    private let sectionVerticalInsets = CGFloat(30)

    // MARK: - Properties
    private let news: News
    private var isCompleted:Bool?

    // MARK: - UI
    private var chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:chaptersCollectionViewFlowLayout)

    private let newsTitleHeaderCellReuseIdentifier = "zhNewsTitleHeader"
    private let newsChapterCellReuseIdentifier = "zhNewsChapterCell"
    private let vocabularyRecapHeaderCellReuseIdentifier = "newVocabularyRecapHeader"
    private let newsRecapVocabularyCellReuseIdentifier = "newsVocabularyCell"
    private let newsRecapFooterCellReuseIdentifier = "newsRecapFooter"

    // MARK: - Datamodels
    private let userDataFetcher = UserDataFetcher.shared
    private let dataFetcher = NewsDataFetcher.init()
    private var newsChapters:[NewsChapter] = []
    private var recapVocabularyList:[Vocabulary] = []
    private var allVocabDict:Dictionary<String, Vocabulary> = [:]
    private var sections:[ChineseNewsSection] = []

    // MARK: MehoAnalytics
    let screenName = "p_meho_stories_chinese"
    let screenClass =  "p_meho_stories_chinese"

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
        dataFetcher.fetchNewsDetail(newsID: news.identifier, completionHandler: {
            (englishChapters, chineseChapters, recabVocabs, allVocabDict, error) in
            if (error == nil && chineseChapters != nil && englishChapters != nil && recabVocabs != nil && allVocabDict != nil) {
                DispatchQueue.main.async {
                    self.newsChapters = chineseChapters!
                    self.recapVocabularyList = recabVocabs!
                    self.allVocabDict = allVocabDict!
                    self.sections.insert(.newsChapters, at: 0)
                    self.sections.insert(.recapVocabularyList, at: 1)
                    self.chaptersCollectionView.reloadData()
                }
            }
        })

        guard let userId = AWSMobileClient.default().userSub else { return }
        userDataFetcher.getUserItemCompleted (userId: userId, itemId: self.news.identifier, completionHandler: { (isCompleted, error) in
            if (error == nil && isCompleted) {
                self.isCompleted = true
            } else {
                self.isCompleted = false
            }
            self.chaptersCollectionView.reloadData()
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    func setUpChapters() {
        chaptersCollectionView.dataSource = self
        chaptersCollectionView.delegate = self
        chaptersCollectionView.backgroundColor = .clear
        chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chaptersCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: trailingLeadingMargin, bottom: 0, right: trailingLeadingMargin)

        // collection layout
        chaptersCollectionViewFlowLayout.scrollDirection = .vertical
        chaptersCollectionViewFlowLayout.minimumLineSpacing = 18
        chaptersCollectionViewFlowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: sectionVerticalInsets, right: 0)

        chaptersCollectionView.register(TwoLineTitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newsTitleHeaderCellReuseIdentifier)
        chaptersCollectionView.register(NewsChapterCollectionViewCell.self, forCellWithReuseIdentifier:newsChapterCellReuseIdentifier)
        chaptersCollectionView.register(OneLineTitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: vocabularyRecapHeaderCellReuseIdentifier)
        chaptersCollectionView.register(NewsRecapVocabularyCollectionViewCell.self, forCellWithReuseIdentifier: newsRecapVocabularyCellReuseIdentifier)

        chaptersCollectionView.register(NewsRecapFooterCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: newsRecapFooterCellReuseIdentifier)

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
            if indexPath.section == 0 {
                if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newsTitleHeaderCellReuseIdentifier, for: indexPath) as? TwoLineTitleHeaderCollectionReusableView {
                    headerView.setHeader(titleEn: news.title_en, titleZh: news.title_zh, maybeDate: news.date)
                    return headerView
                }
            } else if indexPath.section == 1 {
                if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: vocabularyRecapHeaderCellReuseIdentifier, for: indexPath) as? OneLineTitleHeaderCollectionReusableView {
                    headerView.setHeader(title: recapListTitle)
                    return headerView
                }
            }
        } else if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section == 1 {
                if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: newsRecapFooterCellReuseIdentifier, for: indexPath) as? NewsRecapFooterCollectionReusableView {
                    footerView.setDelegate(delegate: self)
                    if let isArticleCompleted = self.isCompleted {
                        if isArticleCompleted {
                            footerView.setCompleted()
                        }
                    }
                    return footerView
                }
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.init(width: 0, height: TwoLineTitleHeaderCollectionReusableView.heightForHeader(with :collectionView.contentSize.width, titleEn: news.title_en, titleZh: news.title_zh, maybeDate:news.date))
        } else { // assuming only two sections!
            return CGSize.init(width: 0, height: OneLineTitleHeaderCollectionReusableView.heightForHeader(with :collectionView.contentSize.width, title: news.title_en))
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize.init(width: 0, height: NewsRecapFooterCollectionReusableView.cellHeight(with :collectionView.contentSize.width))
        } else { // assuming only two sections!
            return CGSize.init(width: 0, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let detailedNewsSections = sections[section]
        switch detailedNewsSections {
        case .newsChapters:
            return newsChapters.count
        case .recapVocabularyList:
            return recapVocabularyList.count
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
        case .recapVocabularyList:
            let vocabulary = recapVocabularyList[indexPath.item]
            return CGSize(width: width, height: NewsRecapVocabularyCollectionViewCell.cellHeight(with: width, vocabulary: vocabulary))
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let detailedNewsSections = sections[indexPath.section]
        switch detailedNewsSections {
        case .newsChapters:
            let chapter = newsChapters[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsChapterCellReuseIdentifier, for: indexPath) as! NewsChapterCollectionViewCell
            cell.newsChapter = chapter
            cell.setDelegate(delegate: self)
            return cell
        case .recapVocabularyList:
            let vocabulary = recapVocabularyList[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newsRecapVocabularyCellReuseIdentifier, for: indexPath) as! NewsRecapVocabularyCollectionViewCell
            cell.vocabulary = vocabulary
            return cell
        }
    }

    // MARK: - NewsChapterCollectionViewCellDelegate
    func NewsChapterCollectionViewCellDidTapVocabulary(vocabularyId: String) {
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_stories_chinese-view_vocabulary",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_vocabulary",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        if let userId = AWSMobileClient.default().userSub {
            self.userDataFetcher.getUserVocabularySave (userId: userId, vocaularyId: vocabularyId, completionHandler: { (isSaved, error) in
                    DispatchQueue.main.async {
                        let isSaved = error == nil && isSaved
                        self.openUnsavedVocabPopUp(vocabularyId: vocabularyId, isSaved: isSaved)
                    }
                }
            )
        } else {
            openUnsavedVocabPopUp(vocabularyId: vocabularyId, isSaved: false)
        }
    }

    func openUnsavedVocabPopUp(vocabularyId: String, isSaved: Bool) {
        if let vocabulary = self.allVocabDict[vocabularyId] {
            let vocabularyViewController = VocabularyViewController.init(vocabulary: vocabulary, isSaved: isSaved)
            vocabularyViewController.modalPresentationStyle = .overFullScreen
            vocabularyViewController.modalTransitionStyle = .crossDissolve
            self.navigationController?.present(vocabularyViewController, animated: true, completion: nil)
        }
    }

    // MARK: - NewsRecapFooterCollectionReusableViewDelegate
    func NewsRecapFooterCollectionReusableViewDidTapMarkComplete() {
        if let userId = AWSMobileClient.default().userSub {
            let parameters = [
                MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_storeis_chinese-mark_as_complete",
                MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "mark_as_complete",
                MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
                MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
            ]
            Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
            self.userDataFetcher.deleteUserItemInProgress(userId: userId, itemId: self.news.identifier) { (removeInProgressSuccess, error) in
                if (error == nil && removeInProgressSuccess) {
                    // do nothing
                    print("user:" + userId + ",article:" + self.news.identifier + " - remove inprogress successful")
                } else {
                    print("user:" + userId + ",article:" + self.news.identifier + " - remove inprogress failed")
                }
            }
            self.userDataFetcher.createUserItemCompleted(userId: userId, itemId: self.news.identifier, itemType: "ARTICLE") { (createCompletedSuccess, error) in
                if (error == nil && createCompletedSuccess) {
                    // do nothing
                    print("user:" + userId + ",article:" + self.news.identifier + " - added completed successful")
                } else {
                    print("user:" + userId + ",article:" + self.news.identifier + " - added completed failed")
                }
            }
        }
    }

}
