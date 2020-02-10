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
    
    private let session = URLSession(configuration: .default)
    private let categoriesCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var categoriesCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:categoriesCollectionViewFlowLayout)
    private var categories:[Category] = []
    
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
        
        self.fetchCategories()
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
    
    // MARK: - Private
    
    private func fetchCategories() {
        let categoriesURLString = "http://meho.us-west-2.elasticbeanstalk.com/api/talk/dialogues/category/"
        let categoriesURL = URL.init(string: categoriesURLString)
        if categoriesURL != nil {
            let dataCategoriesTask = session.dataTask(with: categoriesURL!, completionHandler: { (Data, URLResponse, Error) in
                if Error != nil {
                    print("There is an error getting the response of categories")
                    return
                }
                if Data == nil {
                    print("The response of categories is empty")
                    return
                }
                do {
                    if let categoriesJSON = try JSONSerialization.jsonObject(with: Data!, options: []) as? [String: Any] {
                        if let currentCategories = self.parseCurrentCategoriesJSON(categoriesJSON: categoriesJSON) {
                            self.categories = currentCategories
                        }
                        DispatchQueue.main.async {
                            self.categoriesCollectionView.reloadData()
                        }
                    }
                } catch let error as NSError {
                    print("Failed to parse categories JSON: \(error.localizedDescription)")
                }
            })
            dataCategoriesTask.resume()
        }
    }
    
    private func parseCurrentCategoriesJSON(categoriesJSON: Dictionary<String, Any>) -> Array<Category>? {
        if let currentCategoriesJSON = categoriesJSON["results"] as? [Dictionary<String, Any>] {
            var currentCategories:[Category] = []
            for currentCategoryJSON in currentCategoriesJSON {
                var category = Category.init()
                if let title = currentCategoryJSON["name"] as? String {
                    category.title = title
                }
                if let identifier = currentCategoryJSON["id"] as? Int {
                    category.identifier = identifier
                }
                if let coverImageIdentifier = currentCategoryJSON["cover_image_id"] as? String {
                    category.coverImageIdentifier = coverImageIdentifier
                }
                if let coverImageURLString = currentCategoryJSON["cover_image"] as? String {
                    let coverImageURL = URL.init(string: coverImageURLString)
                    category.coverImageURL = coverImageURL
                }
                currentCategories.append(category)
            }
            return currentCategories
        }
        return nil
    }
}
