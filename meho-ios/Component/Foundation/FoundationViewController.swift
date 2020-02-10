//
//  FoundationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation

class FoundationViewController: UIViewController {
    
    // MARK: - Constants
    
    private let foundationTabBarItemImageName = "tabbar_foundation_25pt"
    private let foundationTabBarItemSelectedImageName = "tabbar_foundation_selected_25pt"
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let foundationTabBarItemImage = UIImage.init(named: foundationTabBarItemImageName)
        let foundationTabBarItem = UITabBarItem.init(title: nil, image: foundationTabBarItemImage, tag: 0)
        let foundationTabBarItemSelectedImage = UIImage.init(named: foundationTabBarItemImageName)
        foundationTabBarItem.selectedImage = foundationTabBarItemSelectedImage
        self.tabBarItem = foundationTabBarItem
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
        self.view.backgroundColor = .white
    }
}
