//
//  ProfileViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class ProfileViewController: UIViewController {
    
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
    
    // MARK: - Properties
    private lazy var logoutButton:UIButton = {
        let logoutButton = UIButton.init()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Logout ", for: UIControl.State.normal)
        logoutButton.sizeToFit()
        logoutButton.backgroundColor = .wisteriaPurple

        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return logoutButton
    } ()

    private lazy var usernameLabel:UILabel = {
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

    private lazy var settingButton:UIButton = {
        let button = UIButton.init()
        let profileImage = UIImage.init(named:settingButtonImageName)
        button.setImage(profileImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    } ()

    // MARK: - Datamodels
    private let userDataFetcher = UserDataFetcher.init()

    
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
    
    // MARK - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let margins = view.layoutMarginsGuide

        view.addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: headerHorizontalMargin).isActive = true
        profileImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: headerTopMargin).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true


        view.addSubview(usernameLabel)
        usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: profileToUsernameMargin).isActive = true
        usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true

        view.addSubview(settingButton)
        settingButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        settingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -headerHorizontalMargin).isActive = true
        settingButton.heightAnchor.constraint(equalToConstant: settingButtonSize).isActive = true
        settingButton.widthAnchor.constraint(equalToConstant: settingButtonSize).isActive = true


        view.addSubview(logoutButton)

        logoutButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        logoutButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: CGFloat(30)).isActive = true
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
    }

    
    
    // MARK - Auth related
    @objc
    func logout() {
//        let profileSettingViewController = ProfileSettingViewController.init()
//        navigationController?.pushViewController(profileSettingViewController, animated: true)
        AWSMobileClient.default().signOut { (error) in
            guard error == nil else { return }
            self.checkSignIn()
        }
    }
    
    func checkSignIn() {
        if AWSMobileClient.default().isSignedIn {
            self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
        }
        else {
            self.navigationController? .setViewControllers([MehoCoverViewController.init()], animated: false)
        }
    }
}
