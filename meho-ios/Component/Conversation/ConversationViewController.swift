//
//  ConversationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Constants
    
    private let categoryCellReuseIdentifier = "Categories"
    private let categoriesCollectionViewCellWidth = CGFloat(144)
    private let categoriesCollectionViewHeight = CGFloat(105)
    private let categoriesCollectionViewMargin = CGFloat(15)
    private let conversationTabBarItemImageName = "tabbar_conv_25pt"
    private let conversationTabBarItemSelectedImageName = "tabbar_conv_selected_25pt"
    
    // MARK: - Properties
    
    private let categoriesCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var categoriesCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:categoriesCollectionViewFlowLayout)
    private var categories:[Category] = []
    private let dataFecther = ConversationDataFetcher.init()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        let conversationTabBarItemImage = UIImage.init(named: conversationTabBarItemImageName)
        let conversationTabBarItem = UITabBarItem.init(title: nil, image: conversationTabBarItemImage, tag: 0)
        let conversationTabBarItemSelectedImage = UIImage.init(named: conversationTabBarItemImageName)
        conversationTabBarItem.selectedImage = conversationTabBarItemSelectedImage
        self.tabBarItem = conversationTabBarItem
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
        
        // Sets up the categories collection view flow layout.
        categoriesCollectionViewFlowLayout.scrollDirection = .horizontal
        categoriesCollectionViewFlowLayout.itemSize = CGSize(width: categoriesCollectionViewCellWidth, height: categoriesCollectionViewHeight)
        
        // Sets up the categories collection view.
        categoriesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoriesCollectionView.showsHorizontalScrollIndicator = false
        categoriesCollectionView.showsVerticalScrollIndicator = false
        categoriesCollectionView.backgroundColor = .white
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        categoriesCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier:categoryCellReuseIdentifier)
        self.view.addSubview(categoriesCollectionView)
        
        // Sets up layout constrainsts.
        let margins = view.layoutMarginsGuide
        categoriesCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: categoriesCollectionViewMargin).isActive = true
        categoriesCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -categoriesCollectionViewMargin).isActive = true
        categoriesCollectionView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        categoriesCollectionView.heightAnchor.constraint(equalToConstant: categoriesCollectionViewHeight).isActive = true
        
        dataFecther.fetchCategories { (categories, error) in
            if (error == nil && categories != nil) {
                self.categories = categories!
                DispatchQueue.main.async {
                    self.categoriesCollectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        let category = categories[indexPath.item]
        cell.setCategory(category: category)
        return cell
    }
}
