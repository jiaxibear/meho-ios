//
//  ProfileViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
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
    }
    
}
