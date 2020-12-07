//
//  ProfileViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

enum ProfileSection: Int {
    case completed
    case inProgress
    case savedItems
    case savedVocabularies
}

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ProfileHeaderCollectionReusableViewDelegate, DialogModeSelectionViewControllerDelegate {
    
    // MARK: - Constants
    private let profileTabBarItemImageName = "tabbar_profile_25pt"
    private let settingButtonImageName = "profile_setting_icon"
    private let defaultProfileImageName = "no_profile_pic"
    private let headerHorizontalMargin = CGFloat(24)
    private let headerTopMargin = CGFloat(22)
    private let profileToUsernameMargin = CGFloat(15)
    private let usernameLabelFontSize = CGFloat(20)
    private let profileImageViewSize = CGFloat(50)
    private let settingButtonSize = CGFloat(20)
    private let completedCellHeight = CGFloat(90)
    private let sectionLeadingTrailingMargin = CGFloat(18)
    private let sectionTopMargin = CGFloat(18)
    private let sectionInterGroupSpacing = CGFloat(16)
    private let profileCompletedItemCollectionViewCellReusableIdentifier = "profileCompletedItemCollectionViewCellReusableIdentifier"
    private let profileCardCollectionViewCellReusableIdentifier = "profileCardCollectionViewCellReusableIdentifier"
    private let profileDummyCardCollectionViewCellReusableIdentifier = "profileDummyCardCollectionViewCellReusableIdentifier"
    private let collectionViewTopMargin = CGFloat(30)
    private let completedItemColorAlpha = CGFloat(0.3)
    private let profileSectionHeaderEstimatedHeight = CGFloat(60)
    private let profileSectionHeaderReusableIdentifier = "profileSectionHeaderReusableIdentifier"
    private let profileCardWidth = CGFloat(150)
    private let profileCardHeight = CGFloat(210)
    private let profileDummyCardWidth = CGFloat(150)
    private let profileDummyCardHeight = CGFloat(100)

    // MARK: - Properties
    private lazy var usernameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = NSLocalizedString("UserDefaultNickname", comment: "")
        label.textColor = .wisteriaPurple
        let fontDescriptor = UIFont.systemFont(ofSize: usernameLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()

    private lazy var profileImageView: UIImageView = {
        let view = UIImageView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = profileImageViewSize / 2
        let profileImage = UIImage.init(named:defaultProfileImageName)
        view.image = profileImage
        return view
    } ()

    private lazy var settingButton: UIButton = {
        let button = UIButton.init()
        let profileImage = UIImage.init(named:settingButtonImageName)
        button.setImage(profileImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSettingButton), for: .touchUpInside)
        return button
    } ()

    private lazy var collectionViewCompositionalLayout: UICollectionViewCompositionalLayout = {
        let collectionViewCompositionalLayout = UICollectionViewCompositionalLayout.init { (section, environment) -> NSCollectionLayoutSection? in
            let profileSection = self.sections[section]
            switch profileSection {
            case .completed:
                return self.completedItemsLayoutSection()
            case .inProgress:
                return self.profileCardsLayoutSection(hasCards: self.inProgressItems.count > 0)
            case .savedItems:
                return self.profileCardsLayoutSection(hasCards: self.savedItems.count > 0)
            case .savedVocabularies:
                return self.profileCardsLayoutSection(cardWidth: 0, cardHeight: 0)
            }
        }
        return collectionViewCompositionalLayout
    } ()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: collectionViewCompositionalLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(ProfileCompletedItemCollectionViewCell.self, forCellWithReuseIdentifier: profileCompletedItemCollectionViewCellReusableIdentifier)
        collectionView.register(ProfileCardCollectionViewCell.self, forCellWithReuseIdentifier: profileCardCollectionViewCellReusableIdentifier)
        collectionView.register(ProfileDummyCardCollectionViewCell.self, forCellWithReuseIdentifier: profileDummyCardCollectionViewCellReusableIdentifier)
        collectionView.register(ProfileHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileSectionHeaderReusableIdentifier)
        return collectionView
    } ()

    // MARK: - Datamodels
    private let userDataFetcher = UserDataFetcher.shared
    private let profileDataFetcher = ProfileDataFetcher.init()
    private var sections: [ProfileSection] = [.completed, .inProgress, .savedItems, .savedVocabularies]
    private var completedItems: [ProfileCard] = []
    private var completedGroupedItems: [ProfileCompletedItem] = []

    private var inProgressItems: [ProfileCard] = []
    private var savedItems: [ProfileCard] = []
    private var saveVocabularies: [Vocabulary] = []
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let profileTabBarItemImage = UIImage.init(named: profileTabBarItemImageName)
        let profileTabBarItem = UITabBarItem.init(title: "", image: profileTabBarItemImage, tag: 0)
        tabBarItem = profileTabBarItem
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
        title = ""
        view.backgroundColor = .white
        let margins = view.layoutMarginsGuide

        view.addSubview(collectionView)
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(settingButton)

        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: collectionViewTopMargin).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true

        profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: headerHorizontalMargin).isActive = true
        profileImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: headerTopMargin).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true

        usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: profileToUsernameMargin).isActive = true
        usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true

        settingButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        settingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -headerHorizontalMargin).isActive = true
        settingButton.heightAnchor.constraint(equalToConstant: settingButtonSize).isActive = true
        settingButton.widthAnchor.constraint(equalToConstant: settingButtonSize).isActive = true

        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        updateUserNickName(userID: userID)

        profileDataFetcher.fetchProfileDetail(userID: userID) { (profileDetails, error) in
            guard error == nil && profileDetails != nil else {
                return
            }

            self.completedItems = profileDetails!.completedItems
            self.inProgressItems = profileDetails!.inProgressItems
            self.savedItems = profileDetails!.savedItems
            self.saveVocabularies = profileDetails!.savedVocabularies
            var completedStoriesItem = ProfileCompletedItem.init(title: "stories", count: 0, color: UIColor.skyBlue.withAlphaComponent(self.completedItemColorAlpha), type: .completedStories)
            for completedItem in self.completedItems {
                switch completedItem.profileCardType {
                case .story:
                    completedStoriesItem.count += 1
                    completedStoriesItem.items.append(completedItem)
                    break
                default:
                    break
                }
            }
            let completedExpressionsItem = ProfileCompletedItem.init(title: "expressions", count: 0, color: UIColor.periwinkleBlue.withAlphaComponent(self.completedItemColorAlpha), type: .completedExpressions)
            let completedTalksItem = ProfileCompletedItem.init(title: "talks", count: 0, color: UIColor.periwinkle.withAlphaComponent(self.completedItemColorAlpha), type: .completedStories)
            self.completedGroupedItems = [completedStoriesItem, completedExpressionsItem, completedTalksItem]
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let count = navigationController?.viewControllers.count, count > 1 {
            navigationController?.setNavigationBarHidden(false, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        updateUserNickName(userID: userID)
    }

    // MARK: - UICollectionViewDataDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let profileSection = sections[indexPath.section]
        switch profileSection {
        case .completed:
            let item = indexPath.item
            let completedGroupItems = completedGroupedItems[item]
            let items = completedGroupItems.items
            if items.count > 0 {
                let completedItemsViewController = CompletedItemsViewController.init(completedItemsType: completedGroupItems.type, profileCards: completedGroupItems.items)
                navigationController?.pushViewController(completedItemsViewController, animated: true)
            }
            break
        case .inProgress:
            let item = indexPath.item
            if item >= inProgressItems.count {
                return
            }
            let profileCard = inProgressItems[item]
            didSelectProfileCard(profileCard)
            break
        case .savedItems:
            let item = indexPath.item
            if item >= savedItems.count {
                return
            }
            let profileCard = savedItems[item]
            didSelectProfileCard(profileCard)
            break
        case .savedVocabularies:
            break
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let profileSection = sections[indexPath.section]
        switch profileSection {
        case .completed:
            if let completedItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCompletedItemCollectionViewCellReusableIdentifier, for: indexPath) as? ProfileCompletedItemCollectionViewCell {
                completedItemCell.completedItem = completedGroupedItems[indexPath.item]
                return completedItemCell
            }
        case .inProgress:
            if inProgressItems.count == 0 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: profileDummyCardCollectionViewCellReusableIdentifier, for: indexPath)
            } else if let profileCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCardCollectionViewCellReusableIdentifier, for: indexPath) as? ProfileCardCollectionViewCell {
                profileCardCell.profileCard = inProgressItems[indexPath.item]
                return profileCardCell
            }
        case .savedItems:
            if savedItems.count == 0 {
                return collectionView.dequeueReusableCell(withReuseIdentifier: profileDummyCardCollectionViewCellReusableIdentifier, for: indexPath)
            } else if let profileCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCardCollectionViewCellReusableIdentifier, for: indexPath) as? ProfileCardCollectionViewCell {
                profileCardCell.profileCard = savedItems[indexPath.item]
                return profileCardCell
            }
        case .savedVocabularies:
            return UICollectionViewCell.init(frame: .zero)
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let profileSection = sections[section]
        switch profileSection {
        case .completed:
            return completedGroupedItems.count
        case .inProgress:
            let count = inProgressItems.count
            return count > 0 ? count : 1
        case .savedItems:
            let count = savedItems.count
            return count > 0 ? count : 1
        case .savedVocabularies:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileSectionHeaderReusableIdentifier, for: indexPath) as! ProfileHeaderCollectionReusableView
            var title = ""
            var count = 0
            var subtitle: String?
            var itemsType = CompletedItemsType.completedExpressions
            switch sections[indexPath.section] {
            case .completed:
                title = "Your Achivements"
                break
            case .inProgress:
                title = "In Progress Contents"
                count = inProgressItems.count
                subtitle = NSLocalizedString("InProgressContentsSubtitle", comment: "")
                itemsType = .inProgressAll
                break
            case .savedItems:
                title = "Saved Contents"
                count = savedItems.count
                subtitle = NSLocalizedString("SavedContentsSubtitle", comment: "")
                itemsType = .savedAll
                break
            case .savedVocabularies:
                title = "Saved Vocabulary"
                count = saveVocabularies.count
                break
            }
            headerView.profileHeader = ProfileHeader.init(title: title, subtitle: subtitle, count: count, itemsType: itemsType)
            headerView.deleagte = self
            return headerView
        }
        return UICollectionReusableView.init(frame: .zero)
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

    // MARK: - ProfileHeaderCollectionReusableViewDelegate
    func didTapSeeAllButton(profileHeader: ProfileHeader) {
        var profileCards: [ProfileCard] = []
        let itemsType = profileHeader.itemsType
        switch itemsType {
        case .inProgressAll:
            profileCards = inProgressItems
            break
        case .savedAll:
            profileCards = savedItems
            break
        default:
            break
        }
        let completedItemsViewController = CompletedItemsViewController.init(completedItemsType: itemsType, profileCards: profileCards)
        navigationController?.pushViewController(completedItemsViewController, animated: true)
    }

    // MARK: - Private
    private func completedItemsLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupWidth = (collectionView.bounds.width - sectionLeadingTrailingMargin * 2) / 3
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .absolute(groupWidth), heightDimension: .absolute(completedCellHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: sectionLeadingTrailingMargin, bottom: sectionTopMargin, trailing: sectionLeadingTrailingMargin)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(profileSectionHeaderEstimatedHeight))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [headerElement]
        section.supplementariesFollowContentInsets = false
        return section
    }

    private func profileCardsLayoutSection(cardWidth: CGFloat, cardHeight: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .absolute(cardWidth), heightDimension: .absolute(cardHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection.init(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: sectionLeadingTrailingMargin, bottom: sectionTopMargin, trailing: sectionLeadingTrailingMargin)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(profileSectionHeaderEstimatedHeight))
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [headerElement]
        section.supplementariesFollowContentInsets = false
        section.interGroupSpacing = sectionInterGroupSpacing
        return section
    }

    private func profileCardsLayoutSection(hasCards: Bool) -> NSCollectionLayoutSection {
        let groupWidth = hasCards ? profileCardWidth : profileDummyCardWidth
        let groupHeight = hasCards ? profileCardHeight : profileDummyCardHeight
        return profileCardsLayoutSection(cardWidth: groupWidth, cardHeight: groupHeight)
    }

    @objc
    private func didTapSettingButton() {
        let profileSettingViewController = ProfileSettingViewController.init()
        navigationController?.pushViewController(profileSettingViewController, animated: true)
    }

    private func updateUserNickName(userID: String) {
        userDataFetcher.getUser (userId: userID, completionHandler: { (maybeUser, error) in
            if error == nil, let currentUser = maybeUser {
                if currentUser.username != currentUser.email {
                    DispatchQueue.main.async {
                        self.usernameLabel.text = currentUser.username
                    }
                }
            }
        })
    }

    private func didSelectProfileCard(_ profileCard: ProfileCard) {
        switch profileCard.profileCardType {
        case .story:
            if let news = profileCard as? News {
                let detailedNewsViewController = DetailedNewsViewController.init(news: news)
                navigationController?.pushViewController(detailedNewsViewController, animated: true)
            }
            break
        case .talk:
            if let dialog = profileCard as? Dialog {
                presentDialogModeSelectionViewController(dialog: dialog)
            }
            break
        default:
            break
        }
    }

    private func presentDialogModeSelectionViewController(dialog: Dialog) {
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
}
