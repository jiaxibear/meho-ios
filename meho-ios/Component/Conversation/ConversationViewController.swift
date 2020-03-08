//
//  ConversationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(15)
    private let titleLabelFontSize = CGFloat(30)
    private let titleLabelToConversationCollectionViewMargin = CGFloat(24)
    private let headerReuseIdentifier = "Header"
    private let categoryCellReuseIdentifier = "Categories"
    private let dialogCellReuseIdentifier = "Dialogs"
    private let conversationsCollectionViewSectionTopBottomMargin = CGFloat(20)
    private let categorieCollectionViewCellWidth = CGFloat(165)
    private let categorieCollectionViewCellHeight = CGFloat(134)
    private let categorieCollectionViewCellGroupSpacing = CGFloat(16)
    private let categorieCollectionViewSectionHeaderEstimatedHeight = CGFloat(29)
    private let dialogCollectionViewCellHeight = CGFloat(110)
    private let dialogCollectionViewCellGroupSpacing = CGFloat(20)
    private let conversationTabBarItemImageName = "tabbar_conv_25pt"
    private let conversationTabBarItemSelectedImageName = "tabbar_conv_selected_25pt"

    // MARK: - Properties
    // MARK: UI
    private let titleLabel = UILabel.init(frame: .zero)
    private lazy var conversationCollectionViewCompositionalLayout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
      layoutEnvironment: NSCollectionLayoutEnvironment)
        -> NSCollectionLayoutSection? in
        if sectionIndex == 0 {
            return self.categoriesLayoutSection()
        } else {
            return self.dialogsLayoutSection()
        }
    }
    private lazy var conversationCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:conversationCollectionViewCompositionalLayout)
    // MARK: MODEL
    private var categories:[Category] = []
    private var dialogs:[Dialog] = []
    private let dataFecther = ConversationDataFetcher.init()
    private var sectionHeaderTitles:[String] = []

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let conversationTabBarItemImage = UIImage.init(named: conversationTabBarItemImageName)
        let conversationTabBarItem = UITabBarItem.init(title: nil, image: conversationTabBarItemImage, tag: 0)
        let conversationTabBarItemSelectedImage = UIImage.init(named: conversationTabBarItemImageName)
        conversationTabBarItem.selectedImage = conversationTabBarItemSelectedImage
        self.tabBarItem = conversationTabBarItem
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
        navigationController?.setNavigationBarHidden(true, animated: false)
        let margins = view.layoutMarginsGuide

        // Sets up the title.
        titleLabel.text = NSLocalizedString("ConversationTitle", comment: "")
        titleLabel.textColor = .skyBlue
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Sets up the collection view.
        conversationCollectionView.translatesAutoresizingMaskIntoConstraints = false
        conversationCollectionView.backgroundColor = .white
        conversationCollectionView.dataSource = self
        conversationCollectionView.delegate = self
        conversationCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
        conversationCollectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier: dialogCellReuseIdentifier)
        conversationCollectionView.register(ConversationHeaderCollectionReusableView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: headerReuseIdentifier)
        view.addSubview(conversationCollectionView)

        // Sets up layout constrainsts.
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: trailingLeadingMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingLeadingMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true

        conversationCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        conversationCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        conversationCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleLabelToConversationCollectionViewMargin).isActive = true
        conversationCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        dataFecther.fetchCategories { (categories, error) in
            if (error == nil && categories != nil) {
                self.categories = categories!
                let categoriesSectionHeaderTitle = NSLocalizedString("CategoriesTitle", comment: "")
                self.sectionHeaderTitles.insert(categoriesSectionHeaderTitle, at: 0)
                DispatchQueue.main.async {
                    self.conversationCollectionView.reloadData()
                }
            }
        }

        dataFecther.fetchFeaturedDialogs { (dialogs, error) in
            if (error == nil && dialogs != nil) {
                self.dialogs = dialogs!
                let dialogsSectionHeaderTitle = NSLocalizedString("FeaturedTitle", comment: "")
                self.sectionHeaderTitles.append(dialogsSectionHeaderTitle)
                DispatchQueue.main.async {
                    self.conversationCollectionView.reloadData()
                }
            }
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return categories.count
        }
        if section == 1 {
            return dialogs.count
        }
        
        return 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionHeaderTitles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        if section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
            let category = categories[indexPath.item]
            cell.setCategory(category: category)
            return cell
        }
        if section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dialogCellReuseIdentifier, for: indexPath) as! DialogCollectionViewCell
            let dialog = dialogs[indexPath.item]
            cell.setDialog(dialog: dialog)
            return cell
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    // MARK: - Private
    func fetchingDialogs() {
        self.dataFecther.fetchDialogs(category: "", difficulty: "", completionHandler: { (dialogs, error) in
            if (error == nil && dialogs != nil) {
                self.dialogs = dialogs!
                DispatchQueue.main.async {
                    self.conversationCollectionView.reloadData()
                }
            }
        })
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "header" {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ConversationHeaderCollectionReusableView
            headerView.setTitle(sectionHeaderTitles[indexPath.section])
            return headerView
        }

        return UICollectionReusableView.init(frame: .zero)
    }

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
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
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
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
        section.boundarySupplementaryItems = [headerElement]
        return section
    }
}
