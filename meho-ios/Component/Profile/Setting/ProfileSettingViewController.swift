//
//  ProfileSettingViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 9/12/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class ProfileSettingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let collectionViewCellReuseIdentifier = "collectionViewCellReuseIdentifier"
    private let collectionHeaderCellReuseIdentifier = "collectionHeaderCellReuseIdentifier"
    private let sectionTopInset = CGFloat(12)

    // MARK: - Properties
    // MARK: UI
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout.init()
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.sectionInset = UIEdgeInsets.init(top: sectionTopInset, left: 0, bottom: 0, right: 0)
        return collectionViewFlowLayout
    } ()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProfileSettingCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellReuseIdentifier)
        collectionView.register(ProfileSettingHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderCellReuseIdentifier)
        return collectionView
    } ()

    // MARK: Model
    private lazy var profileSettings: [ProfileSetting] = {
        // TODO: Replaced with localized strings.
        let account = ProfileSetting.init(title: "Account", subtitle: nil, type: .account, style: .header)
        let nickname = ProfileSetting.init(title: "Change Nickname", subtitle: nil, type: .nickname, style: .item)
        let password = ProfileSetting.init(title: "Change Password", subtitle: nil, type: .password, style: .item)
        let profiles = ProfileSetting.init(title: "Profiles", subtitle: nil, type: .profiles, style: .header)
        let goals = ProfileSetting.init(title: "Update Goal", subtitle: "Communicated with Business Contacts", type: .goal, style: .item)
        let interests = ProfileSetting.init(title: "Update Interests", subtitle: "#Business #Travel #Culture", type: .interests, style: .item)
        let professions = ProfileSetting.init(title: "Update Professions", subtitle: "Service", type: .professions, style: .item)
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let appVersion = ProfileSetting.init(title: "App Version: \(versionNumber)", subtitle: nil, type: .appVersion, style: .appVersion)
        let contact = ProfileSetting.init(title: "Contact Meho", subtitle: nil, type: .contact, style: .header)
        let privacyPolicy = ProfileSetting.init(title: "Privacy Policy", subtitle: nil, type: .privacy, style: .header)
        let userAgreement = ProfileSetting.init(title: "User Agreement", subtitle: nil, type: .userAgreement, style: .header)
        let signOut = ProfileSetting.init(title: "Sign Out", subtitle: nil, type: .signOut, style: .header)
        return [account, nickname, password, profiles, goals, interests, professions, appVersion, contact, privacyPolicy, userAgreement, signOut]
    } ()

    var userNickname: String?

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
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
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        UserDataFetcher.shared.getUser(userId: userID) { (basicUser, error) in
            if basicUser != nil && error == nil {
                DispatchQueue.main.async {
                    for (index, _) in self.profileSettings.enumerated() {
                        switch self.profileSettings[index].type {
                        case .goal:
                            self.profileSettings[index].subtitle = basicUser?.goals.joined(separator: ", ")
                            break
                        case .interests:
                            self.profileSettings[index].subtitle = basicUser?.interests.joined(separator: ", ")
                            break
                        case .professions:
                            self.profileSettings[index].subtitle = basicUser?.profession
                            break
                        default:
                            break
                        }
                    }
                    self.userNickname = basicUser?.username
                    self.collectionView.reloadData()
                }
            }
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellReuseIdentifier, for: indexPath) as? ProfileSettingCollectionViewCell {
            cell.profileSetting = profileSettings[indexPath.item]
            return cell
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileSettings.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView.init(frame: .zero)
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderCellReuseIdentifier, for: indexPath) as! ProfileSettingHeaderCollectionReusableView
        if userNickname != nil {
            header.userNickName = userNickname!
        }
        return header
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width - collectionView.contentInset.left - collectionView.contentInset.right
        let height = ProfileSettingCollectionViewCell.cellHeight(width: width, profileSetting: profileSettings[indexPath.item])
        return CGSize.init(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.bounds.size.width - collectionView.contentInset.left - collectionView.contentInset.right
        return CGSize.init(width: 0, height: ProfileSettingHeaderCollectionReusableView.viewHeight(width: width))
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let profileSetting = profileSettings[indexPath.item]
        switch profileSetting.type {
        case .goal:
            let viewController = CompleteProfileViewStep2Controller.init(goals: profileSetting.subtitle?.components(separatedBy: ", "), isSingleStep: true)
            navigationController?.pushViewController(viewController, animated: true)
            break
        case .interests:
            let viewController = CompleteProfileViewStep3Controller.init(interests: profileSetting.subtitle?.components(separatedBy: ", "), isSingleStep: true)
            navigationController?.pushViewController(viewController, animated: true)
            break
        case .professions:
            let viewController = CompleteProfileViewStep4Controller.init(profession: profileSetting.subtitle, isSingleStep: true)
            navigationController?.pushViewController(viewController, animated: true)
            break
        case .userAgreement:
            let title = NSLocalizedString("termsOfUse", comment: "")
            let userAgreementURL = Bundle.main.url(forResource: "TermsOfUse", withExtension: "html")!
            let webViewController = WebViewController.init(title: title, contentURL: userAgreementURL)
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .privacy:
            let title = NSLocalizedString("privacyPolicy", comment: "")
            let userAgreementURL = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "html")!
            let webViewController = WebViewController.init(title: title, contentURL: userAgreementURL)
            navigationController?.pushViewController(webViewController, animated: true)
            break
        case .contact:
            let title = NSLocalizedString("contactMehoTitle", comment: "")
            let message = NSLocalizedString("contactMehoMessage", comment: "")
            let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let okTitle = NSLocalizedString("OKButtonTitle", comment: "")
            alertController.addAction(UIAlertAction.init(title: okTitle, style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            break
        case .signOut:
            AWSMobileClient.default().signOut { (error) in
                guard error == nil else {
                    return
                }
                if !AWSMobileClient.default().isSignedIn {
                    UserDataFetcher.shared.deactivateCurrentUser()
                    self.navigationController?.setViewControllers([MehoCoverViewController.init()], animated: false)
                }
            }
            break
        case .nickname:
            let updateNicknameViewController = UpdateNicknameViewController.init()
            navigationController?.pushViewController(updateNicknameViewController, animated: true)
            break
        default:
            break
        }
    }
}
