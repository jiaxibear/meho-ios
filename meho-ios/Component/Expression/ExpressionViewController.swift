//
//  ExpressionViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum ExpressionSection: Int {
    case survivalPhrases
    case trendingPhrases
}

class ExpressionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TriggerProfileViewDelegate, MehoAnalytics {

    // MARK: - Constants
    private let expressionTabBarItemImageName = "tabbar_expression_25pt"
    private let foundationCoverTitle = "Expressions"
    private let businessImageName = "expression_business"
    private let travelImageName = "expression_travel"
    private let titleLabelFontSize = CGFloat(34)

    private let horizontalMargin = CGFloat(15)
    private let titleLabelTopMargin = CGFloat(30)
    private let collectionViewTopMargin = CGFloat(24)
    private let survivalPhrasesGroupSpacing = CGFloat(5)
    private let survivalPhrasesItemInset = CGFloat(2.5)

    private let trendingCollectionViewCellSpacing = CGFloat(20)

    private let sectionHeaderCellReuseIdentifier = "SectionHeaderIdentifier"
    private let trendingPhraseCellReuseIdentifier = "TrendingPhraseCellIdentifier"
    private let survivalPhraseCellReuseIdentifier = "survivalPhraseCellIdentifier"

    // MARK: - Properties
    private lazy var titleView: MainTabTitleView = {
        let titleView = MainTabTitleView.init(frame: .zero)
        titleView.setTitleText(text: foundationCoverTitle)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.setDelegate(delegate: self)
        return titleView
    } ()

    private lazy var expressionCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout = {
        let expressionCollectionViewCompositionalLayout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
          layoutEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in
            let expressionSection = self.sections[sectionIndex]
            switch expressionSection {
            case .trendingPhrases:
                return self.trendingLayoutSection()
            case .survivalPhrases:
                return self.survivalLayoutSection()
            }
        }
        return expressionCollectionViewCompositionalLayout
    } ()

    private lazy var expressionCollectionView: UICollectionView = {
        let expressionCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:expressionCollectionViewCompositionalLayout)
        expressionCollectionView.backgroundColor = .white
        expressionCollectionView.showsVerticalScrollIndicator = false
        expressionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        expressionCollectionView.register(OneLineTitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sectionHeaderCellReuseIdentifier)
        expressionCollectionView.register(TrendingPhraseCollectionViewCell.self, forCellWithReuseIdentifier: trendingPhraseCellReuseIdentifier)
        expressionCollectionView.register(SurvivalPhraseCollectionViewCell.self, forCellWithReuseIdentifier: survivalPhraseCellReuseIdentifier)
        expressionCollectionView.delegate = self
        expressionCollectionView.dataSource = self
        return expressionCollectionView
    } ()

    private var scrollDownTitleHiddenCollectionViewTopConstraint: NSLayoutConstraint!
    private var scrollUpTitleShownCollectionViewTopConstraint: NSLayoutConstraint!

    // MARK: - Datamodels
    private let dataFecther = ExpressionDataFetcher.init()
    private var trendingPhrases: [TrendingPhraseWrapper] = []
    private var sections: [ExpressionSection] = [.survivalPhrases]
    private lazy var survivalPhraseCategories: [SurvivalPhraseCategory] = {
        let basicSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Basic", titleFontSize:12, identifier:.basic, backgroundImage: nil, backgroundColor: .greenBlue)
        let numbersSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Numbers", titleFontSize:12, identifier:.numbers, backgroundImage: nil, backgroundColor: .skyBlue)
        let shoppingSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Shopping", titleFontSize:16, identifier:.shopping,  backgroundImage: nil, backgroundColor: .dustyOrange)
        let travelImage = UIImage.init(named: travelImageName)
        let travelSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Travel", titleFontSize:20, identifier:.travel, backgroundImage: travelImage, backgroundColor: nil)
        let dinningSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Dining", titleFontSize:14, identifier:.dining, backgroundImage: nil, backgroundColor: .wisteriaPurple)
        let businessImage = UIImage.init(named: businessImageName)
        let businessSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Business", titleFontSize:20, identifier:.business, backgroundImage: businessImage, backgroundColor: nil)
        let entertainmentSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Entertainment",titleFontSize:18, identifier:.entertainment, backgroundImage: nil, backgroundColor: .skyBlue)
        let familySurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Family", titleFontSize:12, identifier:.family, backgroundImage: nil, backgroundColor: .greenBlue)
        let flirtingSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Flirting",titleFontSize:12, identifier:.flirting, backgroundImage: nil, backgroundColor: .wisteriaPurple)
        let festivitiesSurvivalPhraseCategory = SurvivalPhraseCategory.init(title: "Festivities", titleFontSize:12, identifier:.festivities, backgroundImage: nil, backgroundColor: .dustyOrange)
        return [basicSurvivalPhraseCategory, numbersSurvivalPhraseCategory, shoppingSurvivalPhraseCategory, travelSurvivalPhraseCategory, dinningSurvivalPhraseCategory, businessSurvivalPhraseCategory, entertainmentSurvivalPhraseCategory, familySurvivalPhraseCategory, flirtingSurvivalPhraseCategory, festivitiesSurvivalPhraseCategory]
    } ()

    // MARK: MehoAnalytics
    let screenName = "p_meho_expressions_home"
    let screenClass =  "p_meho_expressions_home"

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let expressionTabBarItemImage = UIImage.init(named: expressionTabBarItemImageName)
        let expressionTabBarItem = UITabBarItem.init(title: nil, image: expressionTabBarItemImage, tag: 0)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupTitleViewConstraint()
        setupExpressionCollectionView()

        dataFecther.fetchTrendingPhrases(completionHandler:  { (phrases, error) in
            if (error == nil && phrases != nil) {
                DispatchQueue.main.async {
                    self.trendingPhrases = phrases!.map({ (trendingPhrase) -> TrendingPhraseWrapper in
                        return TrendingPhraseWrapper.init(trendingPhrase: trendingPhrase)
                    })
                    self.sections.append(.trendingPhrases)
                    self.expressionCollectionView.reloadData()
                }
            }
        })
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

        expressionCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalMargin).isActive = true
        expressionCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalMargin).isActive = true
        scrollDownTitleHiddenCollectionViewTopConstraint = expressionCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        scrollUpTitleShownCollectionViewTopConstraint = expressionCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: collectionViewTopMargin)
        scrollUpTitleShownCollectionViewTopConstraint.isActive = true
        expressionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
            return trendingPhrases.count
        case .survivalPhrases:
            return survivalPhraseCategories.count
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
            cell.setPhrase(phrase)
            return cell
        case .survivalPhrases:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: survivalPhraseCellReuseIdentifier, for: indexPath) as! SurvivalPhraseCollectionViewCell
            let survivalPhraseCategory = survivalPhraseCategories[indexPath.item]
            cell.setSurvivalPhraseCategory(survivalPhraseCategory)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sectionHeaderCellReuseIdentifier, for: indexPath) as! OneLineTitleHeaderCollectionReusableView
            var title: String
            switch sections[indexPath.section] {
            case .survivalPhrases:
                title = NSLocalizedString("SurvivalPhrasesTitle", comment: "")
                break
            case .trendingPhrases:
                title = NSLocalizedString("TrendingPhrasesTitle", comment: "")
                break
            }
            headerView.setTitle(title: title)
            return headerView
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let expressionSection = sections[section]
        if expressionSection == .survivalPhrases {
            let survivalPhrase = survivalPhraseCategories[indexPath.item]
            let survivalPhraseCategoryIdentifier = survivalPhrase.identifier.rawValue
            let parameters = [
                MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_expressions_home-view_" + survivalPhraseCategoryIdentifier.lowercased(),
                MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_" + survivalPhraseCategoryIdentifier.lowercased(),
                MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
                MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
            ]
            Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
            let detailedNewsViewController = DetailedDialogViewController.init(survivalPhraseCategoryIdentifier: survivalPhraseCategoryIdentifier, title: survivalPhrase.title)
            navigationController?.pushViewController(detailedNewsViewController, animated: true)
        } else if expressionSection == .trendingPhrases {
            let trendingPhraseWrapper = trendingPhrases[indexPath.item]
            trendingPhraseWrapper.isExpanded = !trendingPhraseWrapper.isExpanded
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }

    private func survivalLayoutSection() -> NSCollectionLayoutSection {
        // Sets up the bottom group.
        let bottomItemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let bottomItem = NSCollectionLayoutItem.init(layoutSize: bottomItemSize)
        let bottomGroupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
        let bottomGroup = NSCollectionLayoutGroup.horizontal(layoutSize: bottomGroupSize, subitem: bottomItem, count: 2)
        bottomGroup.interItemSpacing = .fixed(survivalPhrasesGroupSpacing)

        // Sets up the top left group.
        let topLeftFirstRowItemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let topLeftFirstRowItem = NSCollectionLayoutItem.init(layoutSize: topLeftFirstRowItemSize)
        let topLeftFirstRowGroupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4))
        let topLeftFirstRowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topLeftFirstRowGroupSize, subitem: topLeftFirstRowItem, count: 2)
        topLeftFirstRowGroup.interItemSpacing = .fixed(survivalPhrasesGroupSpacing)
        let topLeftSecondItemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4))
        let topLeftSecondItem = NSCollectionLayoutItem.init(layoutSize: topLeftSecondItemSize)
        topLeftSecondItem.contentInsets = NSDirectionalEdgeInsets(top: survivalPhrasesItemInset * 2, leading: 0, bottom: survivalPhrasesItemInset, trailing: 0)
        let topLeftThirdItemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2))
        let topLeftThirdItem = NSCollectionLayoutItem.init(layoutSize: topLeftThirdItemSize)
        topLeftThirdItem.contentInsets = NSDirectionalEdgeInsets(top: survivalPhrasesItemInset, leading: 0, bottom: 0, trailing: 0)
        let topLeftGroupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(2/5), heightDimension: .fractionalHeight(1))
        let topLeftGroup = NSCollectionLayoutGroup.vertical(layoutSize: topLeftGroupSize, subitems: [topLeftFirstRowGroup, topLeftSecondItem, topLeftThirdItem])
        topLeftGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: survivalPhrasesItemInset)

        // Sets up the top right group.
        let topRightFirstColumnFirstRowItemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let topRightFirstColumnFirstRowItem = NSCollectionLayoutItem.init(layoutSize: topRightFirstColumnFirstRowItemSize)
        let topRightFirstColumnFirstRowGroupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let topRightFirstColumnFirstRowGroup = NSCollectionLayoutGroup.vertical(layoutSize: topRightFirstColumnFirstRowGroupSize, subitem: topRightFirstColumnFirstRowItem, count: 1)
        topRightFirstColumnFirstRowGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: survivalPhrasesItemInset)
        topRightFirstColumnFirstRowGroup.interItemSpacing = .fixed(survivalPhrasesGroupSpacing)
        let topRightSecondColumnFirstRowItemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1))
        let topRightSecondColumnFirstRowItem = NSCollectionLayoutItem.init(layoutSize: topRightSecondColumnFirstRowItemSize)
        topRightSecondColumnFirstRowItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: survivalPhrasesItemInset, bottom: 0, trailing: 0)
        let topRightFirstRowGroupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(2/3))
        let topRightFirstRowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topRightFirstRowGroupSize, subitems: [topRightFirstColumnFirstRowGroup, topRightSecondColumnFirstRowItem])
        topRightFirstRowGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: survivalPhrasesItemInset, trailing: 0)
        let topRightSecondRowFirstItemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1))
        let topRightSecondRowFirstItem = NSCollectionLayoutItem.init(layoutSize: topRightSecondRowFirstItemSize)
        topRightSecondRowFirstItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: survivalPhrasesItemInset)
        let topRightSecondRowSecondItemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let topRightSecondRowSecondItem = NSCollectionLayoutItem.init(layoutSize: topRightSecondRowSecondItemSize)
        topRightSecondRowSecondItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: survivalPhrasesItemInset, bottom: 0, trailing: 0)
        let topRightSecondRowGroupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3))
        let topRightSecondRowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topRightSecondRowGroupSize, subitems: [topRightSecondRowFirstItem, topRightSecondRowSecondItem])
        topRightSecondRowGroup.contentInsets = NSDirectionalEdgeInsets(top: survivalPhrasesItemInset, leading: 0, bottom: 0, trailing: 0)
        let topRightGroupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(3/5), heightDimension: .fractionalHeight(1))
        let topRightGroup = NSCollectionLayoutGroup.vertical(layoutSize: topRightGroupSize, subitems: [topRightFirstRowGroup, topRightSecondRowGroup])
        topRightGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: survivalPhrasesItemInset, bottom: 0, trailing: 0)

        let topGroupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(240))
        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize, subitems: [topLeftGroup, topRightGroup])
        //topGroup.interItemSpacing = .flexible(survivalPhrasesGroupSpacing)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(285))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [topGroup, bottomGroup])
        group.interItemSpacing = .fixed(survivalPhrasesGroupSpacing)
        let section = NSCollectionLayoutSection.init(group: group)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(CGFloat(30)))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [headerElement]
        return section
    }


    // MARK: - Section Layouts
    private func trendingLayoutSection() -> NSCollectionLayoutSection {
        let cellWidth = self.view.bounds.width - 2 * horizontalMargin
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .absolute(cellWidth), heightDimension: .estimated(CGFloat(200)))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .absolute(cellWidth), heightDimension: .estimated(CGFloat(1000)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection.init(group: group)

        section.interGroupSpacing = trendingCollectionViewCellSpacing
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(CGFloat(30)))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [headerElement]
        return section
    }

    // implement for the delegate of TitleView when tapping on profile image, navigate to profile view
    func MainTitleViewDidTapProfileImage() {
        let profileController = ProfileViewController.init()
        navigationController?.pushViewController(profileController, animated: true)
    }
}
