//
//  ConversationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum ConversationSection: Int {
    case categories
    case featuredDialogs
    case mostPopluarDialogs
}

class ConversationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SeeMoreFooterCollectionResuableViewDelegate, TriggerProfileViewDelegate, DialogModeSelectionViewControllerDelegate, MehoAnalytics {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(15)
    private let titleLabelFontSize = CGFloat(30)
    private let titleLabelToConversationCollectionViewMargin = CGFloat(24)
    private let titleLabelTopMargin = CGFloat(30)
    private let headerReuseIdentifier = UICollectionView.elementKindSectionHeader
    private let footerReuseIdentifier = UICollectionView.elementKindSectionFooter
    private let categoryCellReuseIdentifier = "Categories"
    private let dialogCellReuseIdentifier = "Dialogs"
    private let conversationsCollectionViewSectionTopBottomMargin = CGFloat(16)
    private let categorieCollectionViewCellWidth = CGFloat(165)
    private let categorieCollectionViewCellHeight = CGFloat(134)
    private let categorieCollectionViewCellGroupSpacing = CGFloat(16)
    private let categorieCollectionViewSectionHeaderEstimatedHeight = CGFloat(29)
    private let categorieCollectionViewSectionFooterEstimatedHeight = CGFloat(52)
    private let dialogCollectionViewCellHeight = CGFloat(110)
    private let dialogCollectionViewCellGroupSpacing = CGFloat(20)
    private let conversationTabBarItemImageName = "tabbar_conv_25pt"
    private let numberOfMostPopularDialogs = 11

    // MARK: - Properties
    // MARK: UI
    private let titleView = MainTabTitleView.init(frame: .zero)
    private var conversationCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout?
    private lazy var conversationCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:conversationCollectionViewCompositionalLayout!)

    private var scrollDownTitleHiddenCollectionViewTopConstraint: NSLayoutConstraint!
    private var scrollUpTitleShownCollectionViewTopConstraint: NSLayoutConstraint!

    // MARK: Model
    private var categories:[Category] = []
    private var featuredDialogs:[Dialog] = []
    private var mostPopularDialogs:[Dialog] = []
    private var sections:[ConversationSection] = []
    private let dataFecther = ConversationDataFetcher.init()

    // MARK: MehoAnalytics
    var screenName: String {
        return "p_meho_talks_home"
    }

    var screenClass: String {
        return "p_meho_talks_home"
    }

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let conversationTabBarItemImage = UIImage.init(named: conversationTabBarItemImageName)
        let conversationTabBarItem = UITabBarItem.init(title: nil, image: conversationTabBarItemImage, tag: 0)
        tabBarItem = conversationTabBarItem

        conversationCollectionViewCompositionalLayout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
          layoutEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in
            let conversationSection = self.sections[sectionIndex]
            switch conversationSection {
            case .categories:
                return self.categoriesLayoutSection()
            case .featuredDialogs:
                return self.dialogsLayoutSection()
            case .mostPopluarDialogs:
                return self.dialogsLayoutSection()
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
        let margins = view.layoutMarginsGuide

        // Sets up the title.
        titleView.setTitleText(text: NSLocalizedString("ConversationTitle", comment: ""))
        titleView.setDelegate(delegate: self)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)

        // Sets up the collection view.
        conversationCollectionView.translatesAutoresizingMaskIntoConstraints = false
        conversationCollectionView.backgroundColor = .white
        conversationCollectionView.dataSource = self
        conversationCollectionView.delegate = self
        
        conversationCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
        conversationCollectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier: dialogCellReuseIdentifier)
        conversationCollectionView.register(ConversationHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        conversationCollectionView.register(SeeMoreFooterCollectionResuableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier)
        view.addSubview(conversationCollectionView)

        // Sets up layout constrainsts.
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailingLeadingMargin).isActive = true
        titleView.topAnchor.constraint(equalTo: margins.topAnchor, constant: titleLabelTopMargin).isActive = true

        scrollDownTitleHiddenCollectionViewTopConstraint = conversationCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        scrollUpTitleShownCollectionViewTopConstraint = conversationCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: titleLabelToConversationCollectionViewMargin)
        scrollUpTitleShownCollectionViewTopConstraint.isActive = true
        conversationCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        conversationCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        conversationCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        dataFecther.fetchCategories { (categories, error) in
            if (error == nil && categories != nil) {
                DispatchQueue.main.async {
                    self.categories = categories!
                    self.sections.insert(.categories, at: 0)
                    self.conversationCollectionView.reloadData()
                }
            }
        }

        dataFecther.fetchFeaturedDialogs(difficulty: nil, completionHandler: {
            (dialogs, error) in
            if (error == nil && dialogs != nil) {
                DispatchQueue.main.async {
                    self.featuredDialogs = dialogs!
                    if self.sections.count == 0 {
                        self.sections.append(.featuredDialogs)
                    } else {
                        self.sections.insert(.featuredDialogs, at: 1)
                    }
                    self.conversationCollectionView.reloadData()
                }
            }
        })

        dataFecther.fetchMostPopularDialogs(difficulty: nil, completionHandler: {
            (dialogs, error) in
            if (error == nil && dialogs != nil) {
                DispatchQueue.main.async {
                    self.mostPopularDialogs = Array(dialogs!.prefix(self.numberOfMostPopularDialogs))
                    self.sections.append(.mostPopluarDialogs)
                    self.conversationCollectionView.reloadData()
                }
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
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

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversationSection = sections[indexPath.section]
        switch conversationSection {
        case .categories:
            let category = categories[indexPath.item]
            let dialogStreamViewController = DialogStreamViewController.init(category: category)
            navigationController?.pushViewController(dialogStreamViewController, animated: true)
        case .featuredDialogs:
            let dialog = featuredDialogs[indexPath.item]
            displayDialogModeSelectionViewController(dialog: dialog)
        case .mostPopluarDialogs:
            let dialog = mostPopularDialogs[indexPath.item]
            displayDialogModeSelectionViewController(dialog: dialog)
            break
        }
    }

    // MARK: - DialogModeSelectionViewControllerDelegate
    func dialogModeSelectionViewControllerDidTapDuoRolePlayButton(dialogID: String) {
        dismiss(animated: true) {
            let duoDetailedDialogViewController = DuoDetailedDialogViewController.init(dialogID: dialogID)
            self.navigationController?.pushViewController(duoDetailedDialogViewController, animated: true)
        }
    }

    func dialogModeSelectionViewControllerDidTapSoloPracticeButton(dialogID: String) {
        dismiss(animated: true) {
            let detailedDialogViewController = DetailedDialogViewController.init(dialogID: dialogID)
            self.navigationController?.pushViewController(detailedDialogViewController, animated: true)
        }
    }

    func dialogModeSelectionViewControllerDidTapSaveButton(dialogID: String) {
        view.makeToast(NSLocalizedString("saveSuccessfullyMessage", comment: ""))
    }

    // MARK: - SeeMoreFooterCollectionResuableViewDelegate
    func seeMoreFooterCollectionResuableViewDidTapButton(_ view: SeeMoreFooterCollectionResuableView) {
        var dialogStreamViewController: DialogStreamViewController?
        if view.tag == ConversationSection.mostPopluarDialogs.rawValue {
            dialogStreamViewController = DialogStreamViewController.init(streamType: .mostPopular)
        } else if view.tag == ConversationSection.featuredDialogs.rawValue {
            dialogStreamViewController = DialogStreamViewController.init(streamType: .featured)
        }
        if dialogStreamViewController != nil {
            navigationController?.pushViewController(dialogStreamViewController!, animated: true)
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let conversationSection = sections[section]
        switch conversationSection {
        case .categories:
            return categories.count
        case .featuredDialogs:
            return featuredDialogs.count
        case .mostPopluarDialogs:
            return mostPopularDialogs.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let conversationSection = sections[indexPath.section]
        switch conversationSection {
        case .categories:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
            let category = categories[indexPath.item]
            cell.setCategory(category: category)
            return cell
        case .featuredDialogs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dialogCellReuseIdentifier, for: indexPath) as! DialogCollectionViewCell
            let dialog = featuredDialogs[indexPath.item]
            cell.setDialog(dialog)
            return cell
        case .mostPopluarDialogs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dialogCellReuseIdentifier, for: indexPath) as! DialogCollectionViewCell
            let dialog = mostPopularDialogs[indexPath.item]
            cell.setDialog(dialog)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ConversationHeaderCollectionReusableView
            let conversationSection = sections[indexPath.section]
            headerView.setTitle(self.titleForConversationSection(conversationSection))
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as! SeeMoreFooterCollectionResuableView
            let conversationSection = sections[indexPath.section]
            footerView.tag = conversationSection.rawValue
            footerView.delegate = self
            return footerView
        }

        return UICollectionReusableView.init(frame: .zero)
    }

    // MARK: - Private
    func categoriesLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .absolute(categorieCollectionViewCellWidth), heightDimension: .absolute(categorieCollectionViewCellHeight))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .absolute(categorieCollectionViewCellWidth), heightDimension: .absolute(categorieCollectionViewCellHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = categorieCollectionViewCellGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: conversationsCollectionViewSectionTopBottomMargin, leading: trailingLeadingMargin, bottom: conversationsCollectionViewSectionTopBottomMargin, trailing: trailingLeadingMargin)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(categorieCollectionViewSectionHeaderEstimatedHeight))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [headerElement]
        return section
    }

    func dialogsLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(dialogCollectionViewCellHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.interGroupSpacing = dialogCollectionViewCellGroupSpacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: conversationsCollectionViewSectionTopBottomMargin, leading: trailingLeadingMargin, bottom: conversationsCollectionViewSectionTopBottomMargin, trailing: trailingLeadingMargin)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(categorieCollectionViewSectionHeaderEstimatedHeight))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(categorieCollectionViewSectionFooterEstimatedHeight))
        let footerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        section.boundarySupplementaryItems = [headerElement, footerElement]
        return section
    }

    func titleForConversationSection(_ conversationSection : ConversationSection) -> String {
        switch conversationSection {
        case .categories:
            return NSLocalizedString("CategoriesTitle", comment: "")
        case .featuredDialogs:
            return NSLocalizedString("FeaturedTitle", comment: "")
        case .mostPopluarDialogs:
            return NSLocalizedString("MostPopularTitle", comment: "")
        }
    }

    // implement for the delegate of TitleView when tapping on profile image, navigate to profile view
    func MainTitleViewDidTapProfileImage() {
        let profileController = ProfileViewController.init()
        navigationController?.pushViewController(profileController, animated: true)
    }

    func displayDialogModeSelectionViewController(dialog: Dialog) {
        let dialogModeSelectionViewController = DialogModeSelectionViewController.init(dialog: dialog)
        dialogModeSelectionViewController.delegate = self
        let dialogViewController = DialogViewController.init(contentViewController: dialogModeSelectionViewController)
        dialogViewController.modalPresentationStyle = .overFullScreen
        dialogViewController.modalTransitionStyle = .crossDissolve
        navigationController?.present(dialogViewController, animated: true, completion: nil)
    }
}
