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

    private let contentCategoryColelctionViewCellWidth = CGFloat(80)
    private let contentCategoryColelctionViewCellHeight = CGFloat(30)
    private let contentCategoryCollectionViewCellGroupSpacing = CGFloat(12)
    private let filterCollectionViewSectionHeaderEstimatedHeight = CGFloat(14)
    private let filterCollectionViewSectionTrailingLeadingMargin = CGFloat(24)
    private let filterCollectionViewSectionTopBottomMargin = CGFloat(16)
    private let itemColelctionViewCellHeight = CGFloat(120)
    private let itemCollectionViewCellGroupSpacing = CGFloat(30)
    private let itemCollectionViewSectionTrailingLeadingMargin = CGFloat(16)
    private let itemCollectionViewSectionTopBottomMargin = CGFloat(8)
    private let completedCategoryCollectionViewCellIdentifier = "CompletedCategoryCollectionViewCellIdentifier"
    private let completedNewsCollectionViewCellIdentifier = "CompletedNewsCollectionViewCellIdentifier"
    private let dialogCollectionViewCellIdentifier = "DialogCollectionViewCellIdentifier"

    enum CompletedItemsSection: Int {
        case contentCategories
        case stories
        case expressions
        case talks
    }

    private lazy var collectionViewCompositionalLayout: UICollectionViewCompositionalLayout = {
        let collectionViewCompositionalLayout = UICollectionViewCompositionalLayout.init { (section, environment) -> NSCollectionLayoutSection? in
            switch self.sections[section] {
            case .contentCategories:
                return self.filterLayoutSection()
            case .stories:
                return self.storiesSection()
            default:
                return self.storiesSection()
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
            collectionView.register(CompletedNewsCollectionViewCell.self, forCellWithReuseIdentifier: completedNewsCollectionViewCellIdentifier)
            break
        case .inProgressAll:
            collectionView.register(CompletedCategoryCollectionViewCell.self, forCellWithReuseIdentifier: completedCategoryCollectionViewCellIdentifier)
            collectionView.register(CompletedNewsCollectionViewCell.self, forCellWithReuseIdentifier: completedNewsCollectionViewCellIdentifier)
            collectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier: dialogCollectionViewCellIdentifier)
            break
        case .savedAll:
            collectionView.register(CompletedCategoryCollectionViewCell.self, forCellWithReuseIdentifier: completedCategoryCollectionViewCellIdentifier)
            collectionView.register(CompletedNewsCollectionViewCell.self, forCellWithReuseIdentifier: completedNewsCollectionViewCellIdentifier)
            collectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier: dialogCollectionViewCellIdentifier)
            break
        }

        return collectionView
    } ()

    private var sections: [CompletedItemsSection] = []
    private let completedItemsType: CompletedItemsType
    private var contentCategories: [ProfileContentCategory] = {
        let story = ProfileContentCategory.init(contentType: .story, title: "Story")
        let expression = ProfileContentCategory.init(contentType: .expression, title: "Expression")
        let talk = ProfileContentCategory.init(contentType: .talk, title: "Talk")
        return [story, expression, talk]
    } ()
    private var stories: [News] = []
    private var talks: [Dialog] = []
    private var filteredStories: [News] = []
    private var filteredTalks: [Dialog] = []

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
            title = NSLocalizedString("CompletedStoreisTitle", comment: "")
            break
        case .inProgressAll:
            title = NSLocalizedString("InProgressItemsTitle", comment: "")
            break
        case .savedAll:
            break
        }

        for profileCard in profileCards {
            if let news = profileCard as? News {
                stories.append(news)
            }
            if let dialogue = profileCard as? Dialog {
                talks.append(dialogue)
            }
        }
        filteredTalks = talks
        filteredStories = stories
        updateSections()
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

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .contentCategories:
            contentCategories[indexPath.item].isSelected = !contentCategories[indexPath.item].isSelected
            updateSections()
            break
        case .stories:
            let news = filteredStories[indexPath.item]
            let detailedNewsViewController = DetailedNewsViewController.init(news: news)
            navigationController?.pushViewController(detailedNewsViewController, animated: true)
            break
        default:
            break
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .contentCategories:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: completedCategoryCollectionViewCellIdentifier, for: indexPath) as! CompletedCategoryCollectionViewCell
            cell.contentCategory = contentCategories[indexPath.item]
            return cell
        case .stories:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: completedNewsCollectionViewCellIdentifier, for: indexPath) as! CompletedNewsCollectionViewCell
            cell.news = filteredStories[indexPath.item]
            return cell
        case .talks:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dialogCollectionViewCellIdentifier, for: indexPath) as! DialogCollectionViewCell
            cell.setDialog(filteredTalks[indexPath.item])
            return cell
        case .expressions:
            return UICollectionViewCell.init(frame: .zero)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .contentCategories:
            return contentCategories.count
        case .stories:
            return filteredStories.count
        case .talks:
            return filteredTalks.count
        default:
            return 0
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    // MARK: - Private
    private func filterLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .absolute(contentCategoryColelctionViewCellWidth), heightDimension: .absolute(contentCategoryColelctionViewCellHeight))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .absolute(contentCategoryColelctionViewCellWidth), heightDimension: .absolute(contentCategoryColelctionViewCellHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = contentCategoryCollectionViewCellGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: filterCollectionViewSectionTopBottomMargin, leading: filterCollectionViewSectionTrailingLeadingMargin, bottom: filterCollectionViewSectionTopBottomMargin, trailing: filterCollectionViewSectionTrailingLeadingMargin)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(filterCollectionViewSectionHeaderEstimatedHeight))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [headerElement]
        return section
    }

    private func storiesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemColelctionViewCellHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.interGroupSpacing = itemCollectionViewCellGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: itemCollectionViewSectionTopBottomMargin, leading: itemCollectionViewSectionTrailingLeadingMargin, bottom: itemCollectionViewSectionTopBottomMargin, trailing: itemCollectionViewSectionTrailingLeadingMargin)
        return section
    }

    private func updateSections() {
        sections.removeAll()
        switch completedItemsType {
        case .completedExpressions:
            break
        case .completedTalks:
            break
        case .completedStories:
            break
        case .inProgressAll:
            sections.append(.contentCategories)
            break
        case .savedAll:
            sections.append(.contentCategories)
            break
        }
        if !contentCategories[0].isSelected {
            filteredStories = []
        } else {
            filteredStories = stories
        }
        if filteredStories.count > 0 {
            sections.append(.stories)
        }
        if !contentCategories[2].isSelected {
            filteredTalks = []
        } else {
            filteredTalks = talks
        }
        if filteredTalks.count > 0 {
            sections.append(.talks)
        }
        collectionView.reloadData()
    }
}
