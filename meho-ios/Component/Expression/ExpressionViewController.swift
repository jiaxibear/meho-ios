//
//  ExpressionViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

enum ExpressionSection: Int {
    case trendingPhrases
}

class ExpressionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let expressionTabBarItemImageName = "tabbar_expression_25pt"
    private let foundationCoverTitle = "Expressions"
    private let titleLabelFontSize = CGFloat(34)

    private let horizontalMargin = CGFloat(15)
    private let titleLabelTopMargin = CGFloat(30)
    private let collectionViewTopMargin = CGFloat(24)

    private let trendingCollectionViewCellSpacing = CGFloat(20)

    private let sectionHeaderCellReuseIdentifier = "SectionHeaderIdentifier"
    private let trendingPhraseCellReuseIdentifier = "TrendingPhraseCellIdentifier"

    // MARK: - Properties
    private lazy var titleView: MainTabTitleView = {
        let titleView = MainTabTitleView.init(frame: .zero)
        titleView.setTitleText(text: foundationCoverTitle)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    } ()

    private var expressionCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout?
    private lazy var expressionCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:expressionCollectionViewCompositionalLayout!)

    // MARK: - Datamodels
    private let dataFecther = ExpressionDataFetcher.init()
    private var trendingPhrases:[Phrase] = []
    private var sections:[ExpressionSection] = []

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let expressionTabBarItemImage = UIImage.init(named: expressionTabBarItemImageName)
        let expressionTabBarItem = UITabBarItem.init(title: nil, image: expressionTabBarItemImage, tag: 0)
        tabBarItem = expressionTabBarItem

        expressionCollectionViewCompositionalLayout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
          layoutEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in
            let expressionSection = self.sections[sectionIndex]
            switch expressionSection {
            case .trendingPhrases:
                return self.trendingLayoutSection()
            }
        }
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

        expressionCollectionView.backgroundColor = .white
        expressionCollectionView.showsVerticalScrollIndicator = false
        expressionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        expressionCollectionView.register(NewsOneTitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sectionHeaderCellReuseIdentifier)
        expressionCollectionView.register(TrendingPhraseCollectionViewCell.self, forCellWithReuseIdentifier: trendingPhraseCellReuseIdentifier)
        expressionCollectionView.delegate = self
        expressionCollectionView.dataSource = self

        setupTitleViewConstraint()
        setupExpressionCollectionView()

        dataFecther.fetchTrendingPhrases(completionHandler:  { (phrases, error) in
            if (error == nil && phrases != nil) {
                DispatchQueue.main.async {
                    self.trendingPhrases = phrases!
                    self.sections.insert(.trendingPhrases, at: 0) // Change to 1 once survival section added
                    self.expressionCollectionView.reloadData()
                }
            }
        })

    }

    private func setupTitleViewConstraint() {
        let margins = self.view.layoutMarginsGuide
        view.addSubview(titleView)
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalMargin).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalMargin).isActive = true
        titleView.topAnchor.constraint(equalTo: margins.topAnchor, constant: titleLabelTopMargin).isActive = true
    }

    private func setupExpressionCollectionView() {
        view.addSubview(expressionCollectionView)

        expressionCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalMargin).isActive = true
        expressionCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalMargin).isActive = true
        expressionCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: collectionViewTopMargin).isActive = true
        expressionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let expressionSections = sections[section]
        switch expressionSections {
        case .trendingPhrases:
            return trendingPhrases.count
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
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sectionHeaderCellReuseIdentifier, for: indexPath) as! NewsOneTitleHeaderCollectionReusableView
            headerView.setTitle(titleEn: "Trending Phrase")
            return headerView
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    // NOT CALLED!!!!
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let expressionSection = sections[indexPath.section]
        switch expressionSection {
        case .trendingPhrases:
            let width = collectionView.bounds.width
            let phrase = trendingPhrases[indexPath.item]
            let height = TrendingPhraseCollectionViewCell.cellHeight(with: width, phrase: phrase)
            return CGSize.init(width: width, height: height)
        }
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
}
