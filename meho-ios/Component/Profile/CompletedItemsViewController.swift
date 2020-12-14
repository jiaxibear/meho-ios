//
//  CompletedItemsViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 11/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

enum CompletedItemsType: Int {
    case completedStories
    case completedExpressions
    case completedTalks
    case inProgressAll
    case savedAll
    case savedVocabularies
}

class CompletedItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DialogModeSelectionViewControllerDelegate {

    private let contentCategoryCollectionViewCellWidth = CGFloat(40)
    private let contentCategoryCollectionViewCellHeight = CGFloat(30)
    private let contentCategoryCollectionViewCellGroupSpacing = CGFloat(12)
    private let subTypeContentCategoryCollectionViewCellWidth = CGFloat(60)
    private let subTypeContentCategoryCollectionViewCellHeight = CGFloat(24)
    private let subTypeContentCategoryCollectionViewCellGroupSpacing = CGFloat(8)
    private let filterCollectionViewSectionHeaderEstimatedHeight = CGFloat(14)
    private let filterCollectionViewSectionTrailingLeadingMargin = CGFloat(24)
    private let filterCollectionViewSectionTopMargin = CGFloat(16)
    private let subTypeFilterCollectionViewSectionTopMargin = CGFloat(12)
    private let itemColelctionViewCellHeight = CGFloat(80)
    private let itemCollectionViewCellGroupSpacing = CGFloat(30)
    private let itemCollectionViewSectionTrailingLeadingMargin = CGFloat(16)
    private let itemCollectionViewSectionTopMargin = CGFloat(24)
    private let expressionColelctionViewCellHeight = CGFloat(150)
    private let vocabularyColelctionViewCellHeight = CGFloat(80)
    private let completedCategoryCollectionViewCellIdentifier = "CompletedCategoryCollectionViewCellIdentifier"
    private let completedNewsCollectionViewCellIdentifier = "CompletedNewsCollectionViewCellIdentifier"
    private let completedExpressionCollectionViewCellIdentifier = "completedExpressionCollectionViewCellIdentifier"
    private let dialogCollectionViewCellIdentifier = "DialogCollectionViewCellIdentifier"
    private let completedVocabularyCollectionViewCellIdentifier  = "completedVocabularyCollectionViewCellIdentifier "

    enum CompletedItemsSection: Int {
        case contentCategories
        case storyCategories
        case expressionCategories
        case items
    }

    private lazy var collectionViewCompositionalLayout: UICollectionViewCompositionalLayout = {
        let collectionViewCompositionalLayout = UICollectionViewCompositionalLayout.init { (section, environment) -> NSCollectionLayoutSection? in
            switch self.sections[section] {
            case .contentCategories:
                return self.filterLayoutSection(width: self.contentCategoryCollectionViewCellWidth, height: self.contentCategoryCollectionViewCellHeight, spacing: self.contentCategoryCollectionViewCellGroupSpacing, topMargin: self.filterCollectionViewSectionTopMargin)
            case .expressionCategories:
                fallthrough
            case .storyCategories:
                return self.filterLayoutSection(width: self.subTypeContentCategoryCollectionViewCellWidth, height: self.subTypeContentCategoryCollectionViewCellHeight, spacing: self.subTypeContentCategoryCollectionViewCellGroupSpacing, topMargin: self.subTypeFilterCollectionViewSectionTopMargin)
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
            collectionView.register(CompletedNewsCollectionViewCell.self, forCellWithReuseIdentifier: completedNewsCollectionViewCellIdentifier)
            break
        case .inProgressAll:
            collectionView.register(CompletedCategoryCollectionViewCell.self, forCellWithReuseIdentifier: completedCategoryCollectionViewCellIdentifier)
            collectionView.register(CompletedNewsCollectionViewCell.self, forCellWithReuseIdentifier: completedNewsCollectionViewCellIdentifier)
            collectionView.register(CompletedExpressionCollectionViewCell.self, forCellWithReuseIdentifier: completedExpressionCollectionViewCellIdentifier)
            collectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier: dialogCollectionViewCellIdentifier)
            break
        case .savedAll:
            collectionView.register(CompletedCategoryCollectionViewCell.self, forCellWithReuseIdentifier: completedCategoryCollectionViewCellIdentifier)
            collectionView.register(CompletedNewsCollectionViewCell.self, forCellWithReuseIdentifier: completedNewsCollectionViewCellIdentifier)
            collectionView.register(CompletedExpressionCollectionViewCell.self, forCellWithReuseIdentifier: completedExpressionCollectionViewCellIdentifier)
            collectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier: dialogCollectionViewCellIdentifier)
            break
        case .savedVocabularies:
            collectionView.register(CompletedVocabularyCollectionViewCell.self, forCellWithReuseIdentifier: completedVocabularyCollectionViewCellIdentifier)
        }

        return collectionView
    } ()

    private var sections: [CompletedItemsSection] = []
    private let completedItemsType: CompletedItemsType
    private var contentCategories: [ProfileContentCategory] = {
        var all = ProfileContentCategory.init(categoryType: .all, title: "All", isSubType: false)
        all.isSelected = true
        let story = ProfileContentCategory.init(categoryType: .story, title: "Story", isSubType: false)
        let expression = ProfileContentCategory.init(categoryType: .expression, title: "Expression", isSubType: false)
        let talk = ProfileContentCategory.init(categoryType: .talk, title: "Talk", isSubType: false)
        return [all, story, expression, talk]
    } ()

    private var selectedContentCategoryIndex: Int = 0 {
        didSet {
            contentCategories[oldValue].isSelected = false
            contentCategories[selectedContentCategoryIndex].isSelected = true
            if sections.count == 3 {
                sections.remove(at: 1)
            }
            switch contentCategories[selectedContentCategoryIndex].categoryType {
            case .all:
                filteredItems = items
                collectionView.reloadData()
                break
            case .story:
                filteredItems = stories
                collectionView.reloadData()
                break
            case .expression:
                self.sections.insert(.expressionCategories, at: 1)
                selectedExpressionContentCategoryIndex = 0
                break
            case .talk:
                if talkCategories.count == 0 {
                    conversationDataFetcher.fetchCategories(maybeLimit: nil) { (categories, error) in
                        guard categories != nil else {
                            DispatchQueue.main.async {
                                self.filteredItems = self.talks
                                self.collectionView.reloadData()
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            var allContentCategory = ProfileContentCategory.init(categoryType: .story, title: "All", isSubType: true)
                            allContentCategory.isSelected = true
                            self.talkCategories.append(allContentCategory)
                            for category in categories! {
                                let title = category.title
                                let profileContentCategory = ProfileContentCategory.init(categoryType: .story, title: title, isSubType: true)
                                self.talkCategories.append(profileContentCategory)
                            }
                            self.sections.insert(.storyCategories, at: 1)
                            self.selectedTalkContentCategoryIndex = 0
                        }
                    }
                } else {
                    self.sections.insert(.storyCategories, at: 1)
                    self.selectedTalkContentCategoryIndex = 0
                }
                break
            }
        }
    }

    private var talkCategories: [ProfileContentCategory] = []

    private var selectedTalkContentCategoryIndex: Int = 0 {
        didSet {
            talkCategories[oldValue].isSelected = false
            talkCategories[selectedTalkContentCategoryIndex].isSelected = true
            if selectedTalkContentCategoryIndex == 0 {
                filteredItems = talks
            } else {
                filteredItems.removeAll()
                let title = talkCategories[selectedTalkContentCategoryIndex].title
                for talk in talks {
                    if talk.category?.title == title {
                        filteredItems.append(talk)
                    }
                }
            }
            collectionView.reloadData()
        }
    }

    private lazy var expressionCategories: [ProfileContentCategory] = {
        var expressionCategories: [ProfileContentCategory] = []
        var allCategory = ProfileContentCategory.init(categoryType: .expression, title: "All", isSubType: true)
        allCategory.isSelected = true
        expressionCategories.append(allCategory)
        for value in SurvivalPhraseCategoryIdentifier.allCases {
            let category = ProfileContentCategory.init(categoryType: .expression, title: value.rawValue, isSubType: true)
            expressionCategories.append(category)
        }
        return expressionCategories
    } ()

    private var selectedExpressionContentCategoryIndex: Int = 0 {
        didSet {
            expressionCategories[oldValue].isSelected = false
            expressionCategories[selectedExpressionContentCategoryIndex].isSelected = true
            if selectedExpressionContentCategoryIndex == 0 {
                filteredItems = expressions
            } else {
                filteredItems.removeAll()
                let title = expressionCategories[selectedExpressionContentCategoryIndex].title
                for expression in expressions {
                    if expression.category.rawValue == title {
                        filteredItems.append(expression)
                    }
                }
            }
            collectionView.reloadData()
        }
    }

    private var items: [ProfileCard] = []
    private var stories: [News] = []
    private var talks: [Dialog] = []
    private var expressions: [Expression] = []
    private var vocabularies: [Vocabulary] = []
    private var filteredItems: [ProfileCard] = []
    private let userDataFetcher = UserDataFetcher.shared
    private let conversationDataFetcher = ConversationDataFetcher.init()

    // MARK: - Init
    init() {
        fatalError("init(hasFilter: Boolean, profileItems:[ProfileItem])")
    }

    init(completedItemsType: CompletedItemsType, profileCards: [ProfileCard]) {
        self.completedItemsType = completedItemsType
        super.init(nibName: nil, bundle: nil)
        for profileCard in profileCards {
            if let news = profileCard as? News {
                stories.append(news)
            }
            if let dialogue = profileCard as? Dialog {
                talks.append(dialogue)
            }
            if let expression = profileCard as? Expression {
                expressions.append(expression)
            }
            if let vocabulary = profileCard as? Vocabulary {
                vocabularies.append(vocabulary)
            }
        }
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
            sections.append(.contentCategories)
            break
        case .savedAll:
            title = NSLocalizedString("SavedItemsTitle", comment: "")
            sections.append(.contentCategories)
            break
        case .savedVocabularies:
            title = NSLocalizedString("SavedVocabulariesTitle", comment: "")
            break
        }
        sections.append(.items)
        items = profileCards
        filteredItems = items
        collectionView.reloadData()
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
            let item = indexPath.item
            if item != selectedContentCategoryIndex {
                selectedContentCategoryIndex = item
            }
            break
        case .storyCategories:
            let item = indexPath.item
            if item != selectedTalkContentCategoryIndex {
                selectedTalkContentCategoryIndex = item
            }
            break
        case .expressionCategories:
            let item = indexPath.item
            if item != selectedExpressionContentCategoryIndex {
                selectedExpressionContentCategoryIndex = item
            }
            break
        case .items:
            if let news = filteredItems[indexPath.item] as? News {
                let detailedNewsViewController = DetailedNewsViewController.init(news: news)
                navigationController?.pushViewController(detailedNewsViewController, animated: true)
            } else if let dialog = filteredItems[indexPath.item] as? Dialog {
                guard let userID = AWSMobileClient.default().userSub else {
                    return
                }
                userDataFetcher.getUserItemSave (userId: userID, itemId: dialog.identifier, completionHandler: { (isSaved, error) in
                    if (error == nil && isSaved) {
                        var maybeIsSaved: Bool?
                        if (error == nil) {
                            maybeIsSaved = isSaved
                        }
                        let dialogModeSelectionViewController = DialogModeSelectionViewController.init(dialog: dialog, maybeIsSaved: maybeIsSaved)
                        dialogModeSelectionViewController.delegate = self
                        let dialogViewController = DialogViewController.init(contentViewController: dialogModeSelectionViewController)
                        dialogViewController.modalPresentationStyle = .overFullScreen
                        dialogViewController.modalTransitionStyle = .crossDissolve

                        DispatchQueue.main.async {
                            self.navigationController?.present(dialogViewController, animated: true, completion: nil)
                        }
                    }
                })
            }
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
        case .items:
            let profileCard = filteredItems[indexPath.item]
            if let news = profileCard as? News {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: completedNewsCollectionViewCellIdentifier, for: indexPath) as! CompletedNewsCollectionViewCell
                cell.news = news
                return cell
            } else if let talk = profileCard as? Dialog {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dialogCollectionViewCellIdentifier, for: indexPath) as! DialogCollectionViewCell
                cell.setDialog(talk)
                return cell
            } else if let expression = profileCard as? Expression {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: completedExpressionCollectionViewCellIdentifier, for: indexPath) as! CompletedExpressionCollectionViewCell
                cell.expression = expression
                return cell
            } else if let vocabulary = profileCard as? Vocabulary {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: completedVocabularyCollectionViewCellIdentifier, for: indexPath) as! CompletedVocabularyCollectionViewCell
                cell.setVocabulary(vocabulary)
                return cell
            }
        case .storyCategories:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: completedCategoryCollectionViewCellIdentifier, for: indexPath) as! CompletedCategoryCollectionViewCell
            cell.contentCategory = talkCategories[indexPath.item]
            return cell
        case .expressionCategories:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: completedCategoryCollectionViewCellIdentifier, for: indexPath) as! CompletedCategoryCollectionViewCell
            cell.contentCategory = expressionCategories[indexPath.item]
            return cell
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .contentCategories:
            return contentCategories.count
        case .storyCategories:
            return talkCategories.count
        case .expressionCategories:
            return expressionCategories.count
        case .items:
            return filteredItems.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    // MARK: - DialogModeSelectionViewControllerDelegate
    func dialogModeSelectionViewControllerDidTapDuoRolePlayButton(dialog: Dialog) {
        dismiss(animated: true) {
            let duoDetailedDialogViewController = DuoDetailedDialogViewController.init(dialog: dialog)
            self.navigationController?.pushViewController(duoDetailedDialogViewController, animated: true)
        }
    }

    func dialogModeSelectionViewControllerDidTapSoloPracticeButton(dialog: Dialog) {
        dismiss(animated: true) {
            let detailedDialogViewController = DetailedDialogViewController.init(dialog: dialog)
            self.navigationController?.pushViewController(detailedDialogViewController, animated: true)
        }
    }

    func dialogModeSelectionViewControllerDidTapSaveButton(isSaved: Bool) {
        if isSaved {
            view.makeToast(NSLocalizedString("saveSuccessfullyMessage", comment: ""))
        } else {
            view.makeToast(NSLocalizedString("removeSuccessfullyMessage", comment: ""))
        }
    }

    // MARK: - Private
    private func filterLayoutSection(width: CGFloat, height: CGFloat, spacing: CGFloat, topMargin: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .estimated(width), heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .estimated(width), heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: topMargin, leading: filterCollectionViewSectionTrailingLeadingMargin, bottom: 0, trailing: filterCollectionViewSectionTrailingLeadingMargin)
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(filterCollectionViewSectionHeaderEstimatedHeight))
//        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//        section.boundarySupplementaryItems = [headerElement]
        return section
    }

    private func itemsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(itemColelctionViewCellHeight))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(itemColelctionViewCellHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.interGroupSpacing = itemCollectionViewCellGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: itemCollectionViewSectionTopMargin, leading: itemCollectionViewSectionTrailingLeadingMargin, bottom: 0, trailing: itemCollectionViewSectionTrailingLeadingMargin)
        return section
    }
}
