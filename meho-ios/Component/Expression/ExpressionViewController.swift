//
//  ExpressionViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import Reachability
import AWSMobileClient
import SwiftUI

enum ExpressionSection: Int {
    case survivalPhrases
    case trendingPhrases
}

class ExpressionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TriggerProfileViewDelegate, MehoAnalytics, NewsPlayingNow, NewsPlayingNowViewDelegate, LoadingViewDelegate, TrendingPhraseCollectionViewCellDelegate, ExpressionCollectionReusableViewDelegate {

    // MARK: - Constants
    private let expressionTabBarItemImageName = "tabbar_expression_25pt"
    private let foundationCoverTitle = "Expressions"
    private let businessImageName = "expression_business"
    private let travelImageName = "expression_travel"
    private let titleLabelFontSize = CGFloat(34)

    private let horizontalMargin = CGFloat(16)
    private let titleLabelTopMargin = CGFloat(30)
    private let collectionViewTopMargin = CGFloat(24)
    private let survivalPhrasesGroupSpacing = CGFloat(5)
    private let survivalPhrasesItemInset = CGFloat(2.5)

    private let trendingCollectionViewCellSpacing = CGFloat(20)

    private let sectionHeaderCellReuseIdentifier = "SectionHeaderIdentifier"
    private let trendingPhraseCellReuseIdentifier = "TrendingPhraseCellIdentifier"
    private let survivalPhraseCellReuseIdentifier = "survivalPhraseCellIdentifier"
    private let mustKnowPhraseCategoryCellReuseIdentifier = "mustKnowPhraseCategoryCellReuseIdentifier"
    private let mustKnowPhraseCategoryCellHeight = CGFloat(82)
    private let collectionViewMinimumLineSpacing = CGFloat(16)
    private let collectionViewHeaderHeight = CGFloat(56)
    private let maximumNumberOfTrendingPhrases = Int(3)

    // MARK: - Properties
    private lazy var loadingView: LoadingView = {
        let loadingView = LoadingView.init(frame: .zero)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.delegate = self
        return loadingView
    } ()

    private lazy var titleView: MainTabTitleView = {
        let titleView = MainTabTitleView.init(frame: .zero)
        titleView.setTitleText(text: foundationCoverTitle)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.setDelegate(delegate: self)
        return titleView
    } ()

    private lazy var expressionCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let expressionCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        expressionCollectionViewFlowLayout.minimumLineSpacing = collectionViewMinimumLineSpacing
        return expressionCollectionViewFlowLayout
    } ()

    private lazy var expressionCollectionView: UICollectionView = {
        let expressionCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: expressionCollectionViewFlowLayout)
        expressionCollectionView.backgroundColor = .white
        expressionCollectionView.showsVerticalScrollIndicator = false
        expressionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        expressionCollectionView.register(ExpressionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sectionHeaderCellReuseIdentifier)
        expressionCollectionView.register(TrendingPhraseCollectionViewCell.self, forCellWithReuseIdentifier: trendingPhraseCellReuseIdentifier)
        expressionCollectionView.register(SurvivalPhraseCollectionViewCell.self, forCellWithReuseIdentifier: survivalPhraseCellReuseIdentifier)
        expressionCollectionView.register(MustKnowPhraseCategoryCollectionViewCell.self, forCellWithReuseIdentifier: mustKnowPhraseCategoryCellReuseIdentifier)
        expressionCollectionView.delegate = self
        expressionCollectionView.dataSource = self
        expressionCollectionView.isHidden = true
        return expressionCollectionView
    } ()

    private var trendingPhrasesSet: Set<String> = Set.init()

    private var scrollDownTitleHiddenCollectionViewTopConstraint: NSLayoutConstraint!
    private var scrollUpTitleShownCollectionViewTopConstraint: NSLayoutConstraint!

    // MARK: - Datamodels
    private let dataFecther = ExpressionDataFetcher.init()
    private var trendingPhrases: [TrendingPhraseWrapper] = []
    private var sections: [ExpressionSection] = []
    private var mustKnowPhraseCategories: Array<MustKnowPhraseCategory> = []
    private var showAllTrendingPhrases = false {
        didSet {
            if showAllTrendingPhrases != oldValue {
                expressionCollectionView.reloadSections(IndexSet.init(integer: 0))
            }
        }
    }

    // MARK: MehoAnalytics
    let screenName = "p_meho_expressions_home"
    let screenClass =  "p_meho_expressions_home"

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let expressionTabBarItemImage = UIImage.init(named: expressionTabBarItemImageName)
        let expressionTabBarItem = UITabBarItem.init(title: "", image: expressionTabBarItemImage, tag: 0)
        tabBarItem = expressionTabBarItem
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newsAudioPlayer = NewsAudioPlayer.shared
        if newsAudioPlayer.status != .notStarted, let newsPlayingNowView = newsAudioPlayer.newsPlayingNowView {
            displayNewsPlayingNowView(newsPlayingNowView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(loadingView)

        setupTitleViewConstraint()
        setupExpressionCollectionView()
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: expressionCollectionView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: expressionCollectionView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: expressionCollectionView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: expressionCollectionView.trailingAnchor),
        ])

        fetchTrendingPhrases()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    private func setupTitleViewConstraint() {
        let margins = view.layoutMarginsGuide
        view.addSubview(titleView)
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalMargin).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalMargin).isActive = true
        titleView.topAnchor.constraint(equalTo: margins.topAnchor, constant: titleLabelTopMargin).isActive = true
    }

    private func setupExpressionCollectionView() {
        view.addSubview(expressionCollectionView)

        expressionCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        expressionCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollDownTitleHiddenCollectionViewTopConstraint = expressionCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        scrollUpTitleShownCollectionViewTopConstraint = expressionCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: collectionViewTopMargin)
        scrollUpTitleShownCollectionViewTopConstraint.isActive = true
        expressionCollectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let expressionSections = sections[section]
        switch expressionSections {
        case .trendingPhrases:
            if showAllTrendingPhrases {
                return trendingPhrases.count
            } else {
                return maximumNumberOfTrendingPhrases
            }
        case .survivalPhrases:
            return mustKnowPhraseCategories.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let expressionSection = sections[indexPath.section]
        switch expressionSection {
        case .trendingPhrases:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: trendingPhraseCellReuseIdentifier, for: indexPath) as! TrendingPhraseCollectionViewCell
            let phrase = trendingPhrases[indexPath.item]
            cell.trendingPhraseWrapper = phrase
            return cell
        case .survivalPhrases:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mustKnowPhraseCategoryCellReuseIdentifier, for: indexPath) as! MustKnowPhraseCategoryCollectionViewCell
            let mustKnowPhraseCategory = mustKnowPhraseCategories[indexPath.item]
            cell.mustKnowPhraseCategory = mustKnowPhraseCategory
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sectionHeaderCellReuseIdentifier, for: indexPath) as! ExpressionCollectionReusableView
            var title: String
            var isSeeAllButtonHidden = true
            switch sections[indexPath.section] {
            case .survivalPhrases:
                title = NSLocalizedString("SurvivalPhrasesTitle", comment: "")
                break
            case .trendingPhrases:
                title = NSLocalizedString("TrendingPhrasesTitle", comment: "")
                isSeeAllButtonHidden = false
                break
            }
            headerView.title = title
            headerView.isSeeAllButtonHidden = isSeeAllButtonHidden
            headerView.isSeeAll = !showAllTrendingPhrases
            headerView.delegate = self
            return headerView
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let expressionSection = sections[section]
        if expressionSection == .survivalPhrases {
            let survivalPhrase = mustKnowPhraseCategories[indexPath.item]
            let survivalPhraseCategoryIdentifier = survivalPhrase.title
            let parameters = [
                MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_expressions_home-view_" + survivalPhraseCategoryIdentifier.lowercased(),
                MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_" + survivalPhraseCategoryIdentifier.lowercased(),
                MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
                MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
            ]
            Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
            let detailedNewsViewController = MustKnowPhraseViewController.init(survivalPhraseCategoryIdentifier: survivalPhraseCategoryIdentifier, title: survivalPhrase.title)
            navigationController?.pushViewController(detailedNewsViewController, animated: true)
        } else if expressionSection == .trendingPhrases {
            let item = indexPath.item
            let trendingPhraseWrapper = trendingPhrases[item]
            let newExpandedState = !trendingPhraseWrapper.isExpanded
            trendingPhraseWrapper.isExpanded = newExpandedState
            let controlName = newExpandedState ? "expand_phrase" : "collapse_phrase"
            let parameters = [
                MehoAnalyticsUtils.MehoAnalyticsParameterControlID: screenName,
                MehoAnalyticsUtils.MehoAnalyticsParameterControlName: controlName,
                MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
                MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
            ]
            Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: [indexPath])
            }
            maybeDisplayNotificationSoftAsk(trendingPhrase: trendingPhraseWrapper.trendingPhrase)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width - 2 * horizontalMargin
        var height = CGFloat(0)
        switch sections[indexPath.section] {
        case .survivalPhrases:
            height = mustKnowPhraseCategoryCellHeight
        case .trendingPhrases:
            height = TrendingPhraseCollectionViewCell.cellHeight(with: width, trendingPhraseWrapper: trendingPhrases[indexPath.item])
        }
        return CGSize.init(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.bounds.width - 2 * horizontalMargin
        return CGSize.init(width: width, height: collectionViewHeaderHeight)
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }
        newsPlayingNowView.delegate = self

        view.addSubview(newsPlayingNowView)
        var contentInset = expressionCollectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        expressionCollectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - TrendingPhraseCollectionViewCellDelegate
    func didStartPlayAudio(with trendingPhraseWrapper: TrendingPhraseWrapper) {
        maybeDisplayNotificationSoftAsk(trendingPhrase: trendingPhraseWrapper.trendingPhrase)
    }

    // MARK: - LoadingViewDelegate
    func didTapRetyButton() {
        fetchTrendingPhrases()
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        var contentInset = expressionCollectionView.contentInset
        contentInset.bottom = 0
        expressionCollectionView.contentInset = contentInset
    }

    // implement for the delegate of TitleView when tapping on profile image, navigate to profile view
    func mainTitleViewDidTapProfileImage() {
        if let mainViewController = parent as? MainViewController {
            mainViewController.selectProfileTab()
        }
    }

    // MARK: - ExpressionCollectionReusableViewDelegate
    func didTapSeeAllButton() {
        showAllTrendingPhrases = !showAllTrendingPhrases
    }

    // MARK: - Private

    private func maybeDisplayNotificationSoftAsk(trendingPhrase: TrendingPhrase) {
        trendingPhrasesSet.insert(trendingPhrase.identifier)
        if trendingPhrasesSet.count >= 3 {
            NotificationManager.displayNotificationSoftAsk(type: .trendingPhrases, from: self)
        }
    }

    private func fetchTrendingPhrases() {
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        loadingView.state = .loading
        dataFecther.fetchMustKnowPhrases(userID: userID) { result in
            switch result {
            case.success(let mustKnowPhraseCategories):
                DispatchQueue.main.async {
                    self.mustKnowPhraseCategories = mustKnowPhraseCategories
                    self.sections.append(.survivalPhrases)
                    if self.sections.count == 2 {
                        self.expressionCollectionView.reloadData()
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.expressionCollectionView.isHidden = true
                    let reachability = try! Reachability()
                    if reachability.connection == .unavailable {
                        self.loadingView.state = .noConnection
                    } else {
                        self.loadingView.state = .empty
                    }
                    self.loadingView.isHidden = false
                }
            }
        }
        dataFecther.fetchTrendingPhrases { (result) in
            switch result {
            case .success(let trendingPhrases):
                DispatchQueue.main.async {
                    self.expressionCollectionView.isHidden = false
                    self.loadingView.isHidden = true
                    self.trendingPhrases = trendingPhrases.map({ (trendingPhrase) -> TrendingPhraseWrapper in
                        return TrendingPhraseWrapper.init(trendingPhrase: trendingPhrase)
                    })
                    self.sections.insert(.trendingPhrases, at: 0)
                    if self.sections.count == 2 {
                        self.expressionCollectionView.reloadData()
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.expressionCollectionView.isHidden = true
                    let reachability = try! Reachability()
                    if reachability.connection == .unavailable {
                        self.loadingView.state = .noConnection
                    } else {
                        self.loadingView.state = .empty
                    }
                    self.loadingView.isHidden = false
                }
            }
        }
    }
}

