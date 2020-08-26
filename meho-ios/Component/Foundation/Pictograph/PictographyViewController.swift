//
//  PictographyViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/15/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class PictographyViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constant
    private let navigationHeaderText = "Pictography"
    private let cardHorizontalInsets = CGFloat(17)
    private let cardInterSpacing = CGFloat(14)
    private let pictographCellReuseIdentifier = "pictograph"
    private let navTitleLabelFontSize = CGFloat(18)

    // MARK: - Properties
    private let featureName: String
    private let navTitleLabel = UILabel.init(frame: .zero)
    private let pictographCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var pictographCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:pictographCollectionViewFlowLayout)

    // MARK: - Datamodels
    private let dataFecther = FoundationDataFetcher.init()
    private var pictographList:[Pictograph] = []

    // MARK: - Init
    init() {
        fatalError("Use init")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    init(featureName: String) {
        self.featureName = featureName
        super.init(nibName: nil, bundle: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setUpNavigationBar()
        setupPictographCollectionView()

        dataFecther.fetchPictrographList(completionHandler: { (pictographList, error) in
            if (error == nil && pictographList != nil) {
                DispatchQueue.main.async {
                    self.pictographList = pictographList!
                    self.pictographCollectionView.reloadData()
                }
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let parameters = [
            AnalyticsParameterScreenName: "p_meho_foundations_graphics",
            AnalyticsParameterScreenClass: "p_meho_foundations_graphics",
        ]
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }

    // MARK: - UI elements setup
    func setUpNavigationBar() {
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navTitleLabel.text = navigationHeaderText
        navTitleLabel.textColor = .wisteriaPurple
        let navTitlefontDescriptor = UIFont.systemFont(ofSize: navTitleLabelFontSize, weight: .bold).fontDescriptor.withDesign(.rounded)
        navTitleLabel.font = UIFont.init(descriptor: navTitlefontDescriptor!, size: 0)

        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.titleView = navTitleLabel
    }

    func setupPictographCollectionView() {
        pictographCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pictographCollectionView.backgroundColor = .white
        view.addSubview(pictographCollectionView)

        // view constraints
        let screenHeight = view.frame.height
        pictographCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pictographCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pictographCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: screenHeight/5).isActive = true
        pictographCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -screenHeight/10).isActive = true

        // collection layout
        pictographCollectionViewFlowLayout.scrollDirection = .horizontal
        pictographCollectionViewFlowLayout.minimumInteritemSpacing = cardInterSpacing
        pictographCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: cardHorizontalInsets, bottom: 0, right: cardHorizontalInsets)

        // Sets up cell data
        pictographCollectionView.showsHorizontalScrollIndicator = false
        pictographCollectionView.dataSource = self
        pictographCollectionView.delegate = self
        pictographCollectionView.register(PictographCollectionViewCell.self, forCellWithReuseIdentifier:pictographCellReuseIdentifier)
    }
    

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictographList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pictographCellReuseIdentifier, for: indexPath) as! PictographCollectionViewCell
        let pictograph = pictographList[indexPath.item]
        cell.setPictographCardData(pictograph: pictograph, shouldReverse: (indexPath.item % 2) != 0)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width * 0.8
        let height = min(collectionView.bounds.height, 1.5 * width)
        return CGSize(width: width, height: height)
    }

    // Scroll to next cell if half of current cell is moved out of screen
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        var indexPaths = pictographCollectionView.indexPathsForVisibleItems
        indexPaths.sort()
        var index = indexPaths.first!
        let currentCell = pictographCollectionView.cellForItem(at: index)!
        let position = pictographCollectionView.contentOffset.x - currentCell.frame.origin.x
        if position > (currentCell.frame.size.width / 2) {
           index.row = index.row + 1
        }
        pictographCollectionView.scrollToItem(at: index, at: .left, animated: true )
    }
}
