//
//  ConversationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

enum ConversationSection {
    case categories
    case featuredDialogs
    case mostPopluarDialogs
}

class ConversationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(15)
    private let titleLabelFontSize = CGFloat(30)
    private let titleLabelToConversationCollectionViewMargin = CGFloat(24)
    private let headerReuseIdentifier = "Header"
    private let footerReuseIdentifier = "footer"
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
    private let conversationTabBarItemSelectedImageName = "tabbar_conv_selected_25pt"

    // MARK: - Properties
    // MARK: UI
    private let titleLabel = UILabel.init(frame: .zero)
    private var conversationCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout?
    private lazy var conversationCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:conversationCollectionViewCompositionalLayout!)
    // MARK: MODEL
    private var categories:[Category] = []
    private var featuredDialogs:[Dialog] = []
    private var mostPopularDialogs:[Dialog] = []
    private var sections:[ConversationSection] = []
    private let dataFecther = ConversationDataFetcher.init()

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let conversationTabBarItemImage = UIImage.init(named: conversationTabBarItemImageName)
        let conversationTabBarItem = UITabBarItem.init(title: nil, image: conversationTabBarItemImage, tag: 0)
        let conversationTabBarItemSelectedImage = UIImage.init(named: conversationTabBarItemImageName)
        conversationTabBarItem.selectedImage = conversationTabBarItemSelectedImage
        self.tabBarItem = conversationTabBarItem

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
        conversationCollectionView.register(SeeMoreFooterCollectionResuableView.self, forSupplementaryViewOfKind: "footer", withReuseIdentifier: footerReuseIdentifier)
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
                DispatchQueue.main.async {
                    self.categories = categories!
                    self.sections.insert(.categories, at: 0)
                    self.conversationCollectionView.reloadData()
                }
            }
        }

        dataFecther.fetchFeaturedDialogs { (dialogs, error) in
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
        }

        dataFecther.fetchMostPopularDialogs { (dialogs, error) in
            if (error == nil && dialogs != nil) {
                DispatchQueue.main.async {
                    self.mostPopularDialogs = dialogs!
                    self.sections.append(.mostPopluarDialogs)
                    self.conversationCollectionView.reloadData()
                }
            }
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
            break
        case .mostPopluarDialogs:
            break
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
        if kind == "header" {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ConversationHeaderCollectionReusableView
            let conversationSection = sections[indexPath.section]
            headerView.setTitle(self.titleForConversationSection(conversationSection))
            return headerView
        } else if kind == "footer" {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: "footer", withReuseIdentifier: footerReuseIdentifier, for: indexPath) as! SeeMoreFooterCollectionResuableView
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
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(categorieCollectionViewSectionFooterEstimatedHeight))
        let footerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: "footer", alignment: .bottom)
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
            return NSLocalizedString("MostPopluarTitle", comment: "")
        }
    }
}
