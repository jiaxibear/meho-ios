//
//  FoundationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation

class FoundationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Constants
    private let foundationCoverTitle = "Foundations"
    private let titleLabelFontSize = CGFloat(34)
    private let foundationTabBarItemImageName = "tabbar_foundation_25pt"

    private let titleLabelLeadingMargin = CGFloat(15)
    private let featuresLeadinglMargin = CGFloat(22)
    private let foundationLabelTopMargin = CGFloat(38)
    private let featureCellReuseIdentifier = "Features"
    
    // feature colelction view related, Will tune based on actual iOS design
    private let featuresCollectionViewCellWidth = CGFloat(330)
    private let featuresCollectionViewCellHeight = CGFloat(200)

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
        tabBarItem = foundationTabBarItem
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
        features.append(Feature.init(name: "Pinyin", description: "Pin Yin - Romanized Spelling for Speaking and Typing", imageName: "foundation_feature_pinyin", textColor: .white))
        features.append(Feature.init(name: "Pictography", description: "Xiang Xing Zi - Chinese Character Graphics", imageName: "foundation_feature_pictography", textColor: .black))
    }
    
    // MARK: - Elements layout, style & constrains
    func setupTitleLabelUI() {
        let margins = self.view.layoutMarginsGuide
        titleLabel.numberOfLines = 1
        titleLabel.text = foundationCoverTitle
        titleLabel.textColor = .wisteriaPurple
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: titleLabelLeadingMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -titleLabelLeadingMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: foundationLabelTopMargin).isActive = true
    }
    
    func setupFeatureCollectionViewUI() {
        featuresCollectionView.translatesAutoresizingMaskIntoConstraints = false
        featuresCollectionView.backgroundColor = .white
        self.view.addSubview(featuresCollectionView)
        
        // view constraints
        let margins = self.view.layoutMarginsGuide
        featuresCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: featuresLeadinglMargin).isActive = true
        featuresCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -featuresLeadinglMargin).isActive = true
        featuresCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: featuresCollectionViewTopMargin).isActive = true
        featuresCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -featuresCollectionViewBottomMargin).isActive = true
        
        // collection layout
        featuresCollectionViewFlowLayout.scrollDirection = .vertical
        featuresCollectionViewFlowLayout.minimumLineSpacing = 30
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: featuresCollectionViewCellHeight)

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let foundationItem = features[indexPath.item]
        if foundationItem.name == "Pictography" {
            let pictographyViewController = PictographyViewController.init(featureName:foundationItem.name)
            navigationController?.pushViewController(pictographyViewController, animated: true)
        } else if foundationItem.name == "Pinyin" {
            let pinyinViewController = PinyinViewController.init(featureName:foundationItem.name)
            navigationController?.pushViewController(pinyinViewController, animated: true)
        }
    }
}


