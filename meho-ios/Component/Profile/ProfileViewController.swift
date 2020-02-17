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
    private let logoutButtom = UIButton.init()
    
    
    private let profileTabBarItemImageName = "tabbar_profile_25pt"
    private let profileTabBarItemSelectedImageName = "tabbar_profile_selected_25pt"
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let profileTabBarItemImage = UIImage.init(named: profileTabBarItemImageName)
        let profileTabBarItem = UITabBarItem.init(title: nil, image: profileTabBarItemImage, tag: 0)
        let profileTabBarItemSelectedImage = UIImage.init(named: profileTabBarItemImageName)
        profileTabBarItem.selectedImage = profileTabBarItemSelectedImage
        self.tabBarItem = profileTabBarItem
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
        setupLogoutButtom()
    }
    
    
    // MARK - Elements layout, style & constrains
    func setupLogoutButtom() {
        logoutButtom.translatesAutoresizingMaskIntoConstraints = false
        logoutButtom.setTitle("Logout ", for: UIControl.State.normal)
        logoutButtom.sizeToFit()
        logoutButtom.backgroundColor = .blue
        logoutButtom.layer.borderWidth = 1
        logoutButtom.layer.borderColor = UIColor.black.cgColor
        view.addSubview(logoutButtom)
        let margins = view.layoutMarginsGuide
        logoutButtom.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        logoutButtom.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        logoutButtom.topAnchor.constraint(equalTo: margins.topAnchor, constant: CGFloat(30)).isActive = true
        logoutButtom.heightAnchor.constraint(equalToConstant: CGFloat(35)).isActive = true
        
        logoutButtom.addTarget(self, action: #selector(logout), for: .touchUpInside)
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
            let options = SignInUIOptions(canCancel: false)
            AWSMobileClient.default().showSignIn(navigationController: self.navigationController!, signInUIOptions: options) { (userState, error) in
                guard error == nil else { return }
                guard let state =   userState else { return }
                
                switch state {
                case .signedIn:
                    self.navigationController? .setViewControllers([MainViewController.init()], animated: false)
                default:
                    print ("default")
                }
            }
        }
    }
}
