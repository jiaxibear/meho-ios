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
    
    // MARK: - Properties
    private let logoutButton = UIButton.init()
    
    
    private let profileTabBarItemImageName = "tabbar_profile_25pt"
    
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
        setupLogoutButtom()
    }
    
    
    // MARK - Elements layout, style & constrains
    func setupLogoutButtom() {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Logout ", for: UIControl.State.normal)
        logoutButton.sizeToFit()
        logoutButton.backgroundColor = .wisteriaPurple
        view.addSubview(logoutButton)
        let margins = view.layoutMarginsGuide
        logoutButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        logoutButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: CGFloat(30)).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: CGFloat(35)).isActive = true
        
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    
    // MARK - Auth related
    @objc
    func logout() {
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
