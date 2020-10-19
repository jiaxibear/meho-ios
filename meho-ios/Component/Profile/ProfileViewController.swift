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
    case savedVocabulary
}

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Constants
    private let profileTabBarItemImageName = "tabbar_profile_25pt"
    private let settingButtonImageName = "stories_heart_filled"
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
    private let collectionViewTopMargin = CGFloat(30)
    private let completedItemColorAlpha = CGFloat(0.3)
    private let profileSectionHeaderEstimatedHeight = CGFloat(60)
    private let profileSectionHeaderReusableIdentifier = "profileSectionHeaderReusableIdentifier"
    private let profileCardWidth = CGFloat(110)
    private let profileCardHeight = CGFloat(160)

    // MARK: - Properties
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton.init()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Logout ", for: UIControl.State.normal)
        logoutButton.sizeToFit()
        logoutButton.backgroundColor = .wisteriaPurple
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return logoutButton
    } ()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = "Welcome to Meho!"
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
        view.layer.cornerRadius = profileImageViewSize/2
        let profileImage = UIImage.init(named:defaultProfileImageName)
        view.image = profileImage
        return view
    } ()

    private lazy var settingButton: UIButton = {
        let button = UIButton.init()
        let profileImage = UIImage.init(named:settingButtonImageName)
        button.setImage(profileImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    } ()

    private lazy var collectionViewCompositionalLayout: UICollectionViewCompositionalLayout = {
        let collectionViewCompositionalLayout = UICollectionViewCompositionalLayout.init { (section, environment) -> NSCollectionLayoutSection? in
            let profileSection = self.sections[section]
            switch profileSection {
            case .completed:
                return self.completedItemsLayoutSection()
            case .inProgress:
                fallthrough
            case .savedItems:
                return self.profileCardsLayoutSection()
            case .savedVocabulary:
                return nil
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
        collectionView.register(ProfileHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileSectionHeaderReusableIdentifier)
        return collectionView
    } ()

    // MARK: - Datamodels
    private let userDataFetcher = UserDataFetcher.shared
    private let profileDataFetcher = ProfileDataFetcher.init()
    private var currentUser:BasicUser?
    private let sections: [ProfileSection] = [.completed, .inProgress, .savedItems, .savedVocabulary]
    private lazy var completedItems: [ProfileCompletedItem] = {
        return [completedStories, completedExpressions, completedTalks]
    } ()

    private lazy var completedStories: ProfileCompletedItem = {
        return ProfileCompletedItem.init(title: "stories", count: 0, color: UIColor.skyBlue.withAlphaComponent(completedItemColorAlpha))
    } ()

    private lazy var completedExpressions: ProfileCompletedItem = {
        return ProfileCompletedItem.init(title: "expressions", count: 0, color: UIColor.periwinkleBlue.withAlphaComponent(completedItemColorAlpha))
    } ()

    private lazy var completedTalks: ProfileCompletedItem = {
        return ProfileCompletedItem.init(title: "talks", count: 0, color: UIColor.periwinkle.withAlphaComponent(completedItemColorAlpha))
    } ()

    private lazy var inProgressContents: [ProfileCard] = {
        let card1 = ProfileCard.init(identifier: "", contentType: "Story", titleEn: "Check-in and boarding", titleZh: "值机与登机", imageKey: S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: "ab25a669-49c2-4b6d-8013-ead51c14143d支付宝1.jpg"))
        let card2 = ProfileCard.init(identifier: "", contentType: "Expression", titleEn: "May I have the menu", titleZh: "请给我菜单好吗？", imageKey: S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: "ae40fe25-01f9-4c13-a114-4d218adcd5e9木兰1.jpg"))
        let card3 = ProfileCard.init(identifier: "", contentType: "Talk", titleEn: "Design Discussion", titleZh: "设计讨论", imageKey: S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: "b39863d4-9783-455e-84e7-4afa3ae0ac6f大碗宽面1.jpeg"))
        let card4 = ProfileCard.init(identifier: "", contentType: "Talk", titleEn: "Regional Cuisines in China", titleZh: "中国各地菜系", imageKey: S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: "9580cb81-5821-4da5-9253-ef512f3611df姐姐.jpeg"))
        return [card1, card2, card3, card4]
    } ()

    private lazy var savedItems: [ProfileCard] = {
        let card1 = ProfileCard.init(identifier: "", contentType: "Story", titleEn: "Check-in and boarding", titleZh: "值机与登机", imageKey: S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: "ab25a669-49c2-4b6d-8013-ead51c14143d支付宝1.jpg"))
        let card2 = ProfileCard.init(identifier: "", contentType: "Expression", titleEn: "May I have the menu", titleZh: "请给我菜单好吗？", imageKey: S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: "ae40fe25-01f9-4c13-a114-4d218adcd5e9木兰1.jpg"))
        let card3 = ProfileCard.init(identifier: "", contentType: "Talk", titleEn: "Design Discussion", titleZh: "设计讨论", imageKey: S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: "b39863d4-9783-455e-84e7-4afa3ae0ac6f大碗宽面1.jpeg"))
        let card4 = ProfileCard.init(identifier: "", contentType: "Talk", titleEn: "Regional Cuisines in China", titleZh: "中国各地菜系", imageKey: S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: "9580cb81-5821-4da5-9253-ef512f3611df姐姐.jpeg"))
        return [card1, card2, card3, card4]
    } ()

    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let profileTabBarItemImage = UIImage.init(named: profileTabBarItemImageName)
        let profileTabBarItem = UITabBarItem.init(title: nil, image: profileTabBarItemImage, tag: 0)
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
        navigationController?.setNavigationBarHidden(false, animated: false)
        let margins = view.layoutMarginsGuide

        view.addSubview(collectionView)
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(settingButton)
        view.addSubview(logoutButton)

        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: collectionViewTopMargin).isActive = true

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

        logoutButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        logoutButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: CGFloat(30)).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -CGFloat(10)).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: CGFloat(30)).isActive = true

        guard let userId = AWSMobileClient.default().userSub else { return }
        userDataFetcher.getUser (userId: userId, completionHandler: { (maybeUser, error) in
            if error == nil, let currentUser = maybeUser {

                if currentUser.username != currentUser.email {
                    DispatchQueue.main.async {
                        self.usernameLabel.text = currentUser.username
                    }
                }
                // TODO add avatar related
            }
        })

        profileDataFetcher.fetchUserInteractions (userId: userId, completionHandler: { (maybeCompletedIds, maybeInprogressContents, maybeSavedContents, error) in
            if error == nil, let completedIds = maybeCompletedIds, completedIds.count == 3 {
                let completedArticleIds = completedIds[0]
                self.completedStories.count = completedArticleIds.count
                let completedExpressionIds = completedIds[1]
                self.completedExpressions.count = completedExpressionIds.count
                let completedConversationIds = completedIds[2]
                self.completedTalks.count = completedConversationIds.count
                self.collectionView.reloadData()
            }
        })
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let profileSection = sections[indexPath.section]
        switch profileSection {
        case .completed:
            if let completedItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCompletedItemCollectionViewCellReusableIdentifier, for: indexPath) as? ProfileCompletedItemCollectionViewCell {
                completedItemCell.completedItem = completedItems[indexPath.item]
                return completedItemCell
            }
        case .inProgress:
            if let profileCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCardCollectionViewCellReusableIdentifier, for: indexPath) as? ProfileCardCollectionViewCell {
                profileCardCell.profileCard = inProgressContents[indexPath.item]
                return profileCardCell
            }
        case .savedItems:
            if let profileCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCardCollectionViewCellReusableIdentifier, for: indexPath) as? ProfileCardCollectionViewCell {
                profileCardCell.profileCard = savedItems[indexPath.item]
                return profileCardCell
            }
        case .savedVocabulary:
            return UICollectionViewCell.init(frame: .zero)
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let profileSection = sections[section]
        switch profileSection {
        case .completed:
            return completedItems.count
        case .inProgress:
            return inProgressContents.count
        case .savedItems:
            return savedItems.count
        case .savedVocabulary:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileSectionHeaderReusableIdentifier, for: indexPath) as! ProfileHeaderCollectionReusableView
            var title = ""
            switch sections[indexPath.section] {
            case .completed:
                title = "Your Completed Achivements"
                break
            case .inProgress:
                title = "In Progress Contents"
                break
            case .savedItems:
                title = "Saved Items"
                break
            case .savedVocabulary:
                title = "Saved Vocabulary"
                break
            }
            headerView.profileHeader = ProfileHeader.init(title: title, count: 0)
            return headerView
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    // MARK: - Auth related
    @objc
    func logout() {
        let profileSettingViewController = ProfileSettingViewController.init()
        navigationController?.pushViewController(profileSettingViewController, animated: true)
//        AWSMobileClient.default().signOut { (error) in
//            guard error == nil else { return }
//            self.checkSignIn()
//        }
    }
    
    func checkSignIn() {
        if AWSMobileClient.default().isSignedIn {
            self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
        }
        else {
            self.navigationController? .setViewControllers([MehoCoverViewController.init()], animated: false)
        }
    }

    // MARK: - Private
    func completedItemsLayoutSection() -> NSCollectionLayoutSection {
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

    func profileCardsLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem.init(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize.init(widthDimension: .absolute(profileCardWidth), heightDimension: .absolute(profileCardHeight))
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
}
