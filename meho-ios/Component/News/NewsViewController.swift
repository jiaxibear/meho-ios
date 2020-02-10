//
//  NewsViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    
    // MARK: - Constants
    
    private let newsTabBarItemImageName = "tabbar_news_25pt"
    private let newsTabBarItemSelectedImageName = "tabbar_news_selected_25pt"
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let newsTabBarItemImage = UIImage.init(named: newsTabBarItemImageName)
        let newsTabBarItem = UITabBarItem.init(title: nil, image: newsTabBarItemImage, tag: 0)
        let newsTabBarItemSelectedImage = UIImage.init(named: newsTabBarItemImageName)
        newsTabBarItem.selectedImage = newsTabBarItemSelectedImage
        self.tabBarItem = newsTabBarItem
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
