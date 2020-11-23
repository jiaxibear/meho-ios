//
//  CompletedItemsViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 11/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

enum CompletedItemsType: Int {
    case completedStories
    case completedExpressions
    case completedTalks
    case inProgressAll
    case savedAll
}

class CompletedItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let filterColelctionViewCellWidth = CGFloat(60)
    private let filterColelctionViewCellHeight = CGFloat(24)
    private let filterCollectionViewCellGroupSpacing = CGFloat(8)
    private let filterCollectionViewSectionHeaderEstimatedHeight = CGFloat(14)
    private let filterCollectionViewSectionTrailingLeadingMargin = CGFloat(24)
    private let filterCollectionViewSectionTopBottomMargin = CGFloat(16)
    private let itemColelctionViewCellHeight = CGFloat(120)
    private let itemCollectionViewCellGroupSpacing = CGFloat(30)
    private let itemCollectionViewSectionTrailingLeadingMargin = CGFloat(16)
    private let itemCollectionViewSectionTopBottomMargin = CGFloat(8)
    private let CompletedCategoryCollectionViewCellIdentifier = "CompletedCategoryCollectionViewCellIdentifier"
    private let CompletedNewsCollectionViewCellIdentifier = "CompletedNewsCollectionViewCellIdentifier"

    enum CompletedItemsSection: Int {
        case filter
        case items
    }

    private lazy var collectionViewCompositionalLayout: UICollectionViewCompositionalLayout = {
        let collectionViewCompositionalLayout = UICollectionViewCompositionalLayout.init { (section, environment) -> NSCollectionLayoutSection? in
            switch self.sections[section] {
            case .filter:
                return self.filterLayoutSection()
            case .items:
                return self.itemsSection()
            }
        }
        return collectionViewCompositionalLayout
    } ()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout:collectionViewCompositionalLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self

        switch completedItemsType {
        case .completedExpressions:
            break
        case .completedTalks:
            break
        case .completedStories:
            collectionView.register(CompletedNewsCollectionViewCell.self, forCellWithReuseIdentifier: CompletedNewsCollectionViewCellIdentifier)
            break
        case .inProgressAll:
            collectionView.register(CompletedCategoryCollectionViewCell.self, forCellWithReuseIdentifier: CompletedCategoryCollectionViewCellIdentifier)
            break
        case .savedAll:
            collectionView.register(CompletedCategoryCollectionViewCell.self, forCellWithReuseIdentifier: CompletedCategoryCollectionViewCellIdentifier)
            break
        }

        return collectionView
    } ()

    private var sections: [CompletedItemsSection] = []
    private var profileCards: [ProfileCard] = []
    private let completedItemsType: CompletedItemsType

    // MARK: - Init
    init() {
        fatalError("init(hasFilter: Boolean, profileItems:[ProfileItem])")
    }

    init(completedItemsType: CompletedItemsType, profileCards: [ProfileCard]) {
        self.completedItemsType = completedItemsType
        super.init(nibName: nil, bundle: nil)
        switch completedItemsType {
        case .completedExpressions:
            break
        case .completedTalks:
            break
        case .completedStories:
            self.title = NSLocalizedString("CompletedStoreisTitle", comment: "")
            break
        case .inProgressAll:
            sections.append(.filter)
            break
        case .savedAll:
            sections.append(.filter)
            break
        }

        if profileCards.count > 0 {
            self.profileCards = profileCards
            sections.append(.items)
        }
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(hasFilter: Boolean, profileItems:[ProfileItem])")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(hasFilter: Boolean, profileItems:[ProfileItem])")
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .filter:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompletedCategoryCollectionViewCellIdentifier, for: indexPath)
            return cell
        case .items:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompletedNewsCollectionViewCellIdentifier, for: indexPath) as! CompletedNewsCollectionViewCell
            if let news = profileCards[indexPath.item] as? News {
                cell.news = news
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .filter:
            return 1
        case .items:
            return profileCards.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    // MARK: - Private
    func filterLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .absolute(filterColelctionViewCellWidth), heightDimension: .absolute(filterColelctionViewCellHeight))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .absolute(filterColelctionViewCellWidth), heightDimension: .absolute(filterColelctionViewCellHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = filterCollectionViewCellGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: filterCollectionViewSectionTopBottomMargin, leading: filterCollectionViewSectionTrailingLeadingMargin, bottom: filterCollectionViewSectionTopBottomMargin, trailing: filterCollectionViewSectionTrailingLeadingMargin)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(filterCollectionViewSectionHeaderEstimatedHeight))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [headerElement]
        return section
    }

    func itemsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemColelctionViewCellHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.interGroupSpacing = itemCollectionViewCellGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: itemCollectionViewSectionTopBottomMargin, leading: itemCollectionViewSectionTrailingLeadingMargin, bottom: itemCollectionViewSectionTopBottomMargin, trailing: itemCollectionViewSectionTrailingLeadingMargin)
        return section
    }
}
