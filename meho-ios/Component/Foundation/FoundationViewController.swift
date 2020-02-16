//
//  FoundationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation

class FoundationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Constants
    private let foundationCoverTitle = "Chinese Foundations"
    private let foundationTabBarItemImageName = "tabbar_foundation_25pt"
    private let foundationTabBarItemSelectedImageName = "tabbar_foundation_selected_25pt"
    
    private let foundationHorizontalMargin = CGFloat(15)
    private let foundationLabelTopMargin = CGFloat(22)
    private let featureCellReuseIdentifier = "Features"
    
    // feature colelction view related, Will tune based on actual iOS design
    private let featuresCollectionViewCellWidth = CGFloat(330)
    private let featuresCollectionViewCellHeight = CGFloat(191)
    private let featuresCollectionViewHeight = CGFloat(550)
    private let featuresCollectionViewTopMargin = CGFloat(30)
    private let featuresCollectionViewBottomMargin = CGFloat(30)
    
    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let featuresCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var featuresCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:featuresCollectionViewFlowLayout)
    private var features:[Feature] = []
    
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
        setupTitleLabelUI()
        setupFeatureCollectionViewUI()
    

        // Sets up cell data
        featuresCollectionView.dataSource = self
        featuresCollectionView.delegate = self
        featuresCollectionView.register(FoundationFeatureCollectionViewCell.self, forCellWithReuseIdentifier:featureCellReuseIdentifier)
    
        populateFeatureList()
        self.featuresCollectionView.reloadData()
    }
    
    func populateFeatureList() {
        features.append(Feature.init(name: "pinyin", description: "Pin Yin - Romanized Spelling for Speaking and Typing", imageName: "foundation_feature_pinyin", textColor: .white))
        features.append(Feature.init(name: "hierglyph", description: "Xiang Xing Zi - Chinese Character Graphics", imageName: "foundation_feature_hierglyph", textColor: .black))
        features.append(Feature.init(name: "survival", description: "Sheng Cun Han Yu - Survival Chinese", imageName: "foundation_feature_survival", textColor: .white))
    }
    
    // MARK: - Elements layout, style & constrains
    func setupTitleLabelUI() {
        let margins = self.view.layoutMarginsGuide
        titleLabel.numberOfLines = 1
        titleLabel.text = foundationCoverTitle
        titleLabel.textColor = UIColor.init(red: 125/255, green: 162/255, blue: 255/255, alpha: 1.0)
        titleLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(24))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: foundationHorizontalMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -foundationHorizontalMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: foundationLabelTopMargin).isActive = true
    }
    
    func setupFeatureCollectionViewUI() {
        featuresCollectionView.translatesAutoresizingMaskIntoConstraints = false
        featuresCollectionView.backgroundColor = .white
        self.view.addSubview(featuresCollectionView)
        
        // view constraints
        let margins = self.view.layoutMarginsGuide
        featuresCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: foundationHorizontalMargin).isActive = true
        featuresCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -foundationHorizontalMargin).isActive = true
        featuresCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: featuresCollectionViewTopMargin).isActive = true
        featuresCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -featuresCollectionViewBottomMargin).isActive = true
        
        // collection layout
        featuresCollectionViewFlowLayout.scrollDirection = .vertical
        featuresCollectionViewFlowLayout.minimumInteritemSpacing = 2
        featuresCollectionViewFlowLayout.minimumLineSpacing = 30
        featuresCollectionViewFlowLayout.itemSize = CGSize(width: featuresCollectionViewCellWidth, height: featuresCollectionViewCellHeight)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: featureCellReuseIdentifier, for: indexPath) as! FoundationFeatureCollectionViewCell
        let feature = features[indexPath.item]
        cell.setFeatureCardData(feature: feature)
        return cell
    }
}


