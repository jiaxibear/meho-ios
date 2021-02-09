//
//  FoundationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAnalytics

class FoundationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TriggerProfileViewDelegate, MehoAnalytics, NewsPlayingNow, NewsPlayingNowViewDelegate {
    
    // MARK: - Constants
    private let foundationCoverTitle = "Foundations"
    private let titleLabelFontSize = CGFloat(34)
    private let foundationTabBarItemImageName = "tabbar_foundation_25pt"

    private let titleLabelLeadingMargin = CGFloat(15)
    private let featuresMargin = CGFloat(22)
    private let foundationLabelTopMargin = CGFloat(30)
    private let featureCellReuseIdentifier = "Features"
    
    // feature colelction view related, Will tune based on actual iOS design
    private let featuresCollectionViewCellWidth = CGFloat(330)
    private let featuresCollectionViewCellHeight = CGFloat(200)

    private let featuresCollectionViewTopMargin = CGFloat(30)
    private let featuresCollectionViewBottomMargin = CGFloat(18)
    
    // MARK: - Properties
    // MARK: UI
    private let titleView = MainTabTitleView.init(frame: .zero)
    private let featuresCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var featuresCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:featuresCollectionViewFlowLayout)

    // MARK: Data
    private var features:[Feature] = []

    // MARK: MehoAnalytics
    let screenName = "p_meho_foundations_home"
    let screenClass = "p_meho_foundations_home"
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        let foundationTabBarItemImage = UIImage.init(named: foundationTabBarItemImageName)
        let foundationTabBarItem = UITabBarItem.init(title: "", image: foundationTabBarItemImage, tag: 0)
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
        populateFeatureList()
        self.featuresCollectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newsAudioPlayer = NewsAudioPlayer.shared
        if newsAudioPlayer.status != .notStarted, let newsPlayingNowView = newsAudioPlayer.newsPlayingNowView {
            displayNewsPlayingNowView(newsPlayingNowView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }
    
    func populateFeatureList() {
        features.append(Feature.init(name: "Pinyin", description: "Pin Yin - Romanized Spelling for Speaking and Typing", imageName: "foundation_feature_pinyin", textColor: .white))
        features.append(Feature.init(name: "Pictography", description: "Xiang Xing Zi - Chinese Character Graphics", imageName: "foundation_feature_pictography", textColor: .black))
        features.append(Feature.init(name: "Idoms", description: "Cheng Yu Su Yu - Chinese Idioms & Proverbs", imageName: "foundation_feature_idioms", textColor: .black))
    }
    
    // MARK: - Elements layout, style & constrains
    func setupTitleLabelUI() {
        let margins = self.view.layoutMarginsGuide
        titleView.setTitleText(text: foundationCoverTitle)
        titleView.setDelegate(delegate: self)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: titleLabelLeadingMargin).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -titleLabelLeadingMargin).isActive = true
        titleView.topAnchor.constraint(equalTo: margins.topAnchor, constant: foundationLabelTopMargin).isActive = true
    }
    
    func setupFeatureCollectionViewUI() {
        featuresCollectionView.translatesAutoresizingMaskIntoConstraints = false
        featuresCollectionView.backgroundColor = .white
        self.view.addSubview(featuresCollectionView)
        
        // view constraints
        let margins = self.view.layoutMarginsGuide
        featuresCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: featuresMargin).isActive = true
        featuresCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -featuresMargin).isActive = true
        featuresCollectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: featuresCollectionViewTopMargin).isActive = true
        featuresCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -featuresCollectionViewBottomMargin).isActive = true
        
        // collection layout
        featuresCollectionViewFlowLayout.scrollDirection = .vertical
        featuresCollectionViewFlowLayout.minimumLineSpacing = featuresMargin

        // Sets up cell data
        featuresCollectionView.dataSource = self
        featuresCollectionView.delegate = self
        featuresCollectionView.register(FoundationFeatureCollectionViewCell.self, forCellWithReuseIdentifier:featureCellReuseIdentifier)
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
        let height = collectionView.bounds.height * 0.3
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let foundationItem = features[indexPath.item]
        var controlID = ""
        var controlName = ""
        if foundationItem.name == "Pictography" {
            let pictographyViewController = PictographyViewController.init(featureName:foundationItem.name)
            navigationController?.pushViewController(pictographyViewController, animated: true)
            controlID = "p_meho_foundations-view_foundations_graphics"
            controlName = "view_foundations_graphics"
        } else if foundationItem.name == "Pinyin" {
            let pinyinViewController = PinyinViewController.init(featureName:foundationItem.name)
            navigationController?.pushViewController(pinyinViewController, animated: true)
            controlID = "p_meho_foundations-view_foundations_pinyin"
            controlName = "view_foundations_pinyin"
        } else if foundationItem.name == "Idoms" {
            let idomsViewController = IdiomViewController.init()
            navigationController?.pushViewController(idomsViewController, animated: true)
            controlID = "p_meho_foundations-view_foundations_idioms"
            controlName = "view_foundations_idioms"
        }
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: controlID,
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: controlName,
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
    }

    // implement for the delegate of TitleView when tapping on profile image, navigate to profile view
    func mainTitleViewDidTapProfileImage() {
        if let mainViewController = parent as? MainViewController {
            mainViewController.selectProfileTab()
        }
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }
        newsPlayingNowView.delegate = self

        view.addSubview(newsPlayingNowView)
        var contentInset = featuresCollectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        featuresCollectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        var contentInset = featuresCollectionView.contentInset
        contentInset.bottom = 0
        featuresCollectionView.contentInset = contentInset
    }
}


