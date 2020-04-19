//
//  PinyinViewController.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/15/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PinyinViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let navigationHeaderText = "拼音基础 Pinyin"
    private let plusImageName = "stories_heart_filled"
    private let navTitleLabelFontSize = CGFloat(18)
    private let pillCornerRadius = CGFloat(10)
    private let pillBorderWidth = CGFloat(2)
    private let topLabelFontSize = CGFloat(15)
    private let topSectionHeight = CGFloat(30)

    private let initialCellReuseIdentifier = "InitialCell"
    private let finalCellReuseIdentifier = "finalCell"

    // MARK: - Properties
    private let featureName: String
    private let navTitleLabel = UILabel.init(frame: .zero)

    private let initialCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var initialCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:initialCollectionViewFlowLayout)

    // Top section
    private let initialLabel = UILabel.init(frame: .zero)
    private let finalLabel = UILabel.init(frame: .zero)
    private let plusImageView = UIImageView.init(frame: .zero)

    // MARK: - Data
    private var initials:[String] = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n",
                                     "p", "q", "r", "s", "t", "w", "x", "y", "z", "zh", "ch", "sh"]
    private var finals:[String] = ["a", "ai", "ao", "an", "ang", "e", "ei", "en", "eng", "er",
                                   "i", "ia", "ian", "iang", "iao", "ie", "iong", "iu", "in", "ing",
                                   "o", "ou", "ong", "u", "ua"]


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
        view.backgroundColor = .white

        setUpNavigationBar()
        setupTopSection()
        setupInitialCollectionView()
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

    func setupTopSection() {
        let topLabelFontDescriptor = UIFont.systemFont(ofSize: topLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        let topLabelFont = UIFont.init(descriptor: topLabelFontDescriptor!, size: 0)

        initialLabel.layer.cornerRadius = pillCornerRadius
        initialLabel.clipsToBounds = true
        initialLabel.layer.borderColor = UIColor.skyBlue.cgColor
        initialLabel.layer.borderWidth = pillBorderWidth
        initialLabel.font = topLabelFont
        initialLabel.text = "Initial"
        initialLabel.textAlignment = .center
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(initialLabel)

        finalLabel.layer.cornerRadius = pillCornerRadius
        finalLabel.clipsToBounds = true
        finalLabel.layer.borderColor = UIColor.skyBlue.cgColor
        finalLabel.layer.borderWidth = pillBorderWidth
        finalLabel.font = topLabelFont
        finalLabel.text = "Final"
        finalLabel.textAlignment = .center
        finalLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(finalLabel)

        plusImageView.image = UIImage.init(named: plusImageName)
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusImageView)

        plusImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: CGFloat(20)).isActive = true
        plusImageView.heightAnchor.constraint(equalToConstant: topSectionHeight).isActive = true
        plusImageView.widthAnchor.constraint(equalToConstant: CGFloat(32)).isActive = true

        initialLabel.centerYAnchor.constraint(equalTo: plusImageView.centerYAnchor).isActive = true
        initialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -view.bounds.width * 0.25).isActive = true
        initialLabel.heightAnchor.constraint(equalToConstant: topSectionHeight).isActive = true
        initialLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.25).isActive = true

        finalLabel.centerYAnchor.constraint(equalTo: plusImageView.centerYAnchor).isActive = true
        finalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.bounds.width * 0.25).isActive = true
        finalLabel.heightAnchor.constraint(equalToConstant: topSectionHeight).isActive = true
        finalLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.25).isActive = true
    }

    func setupInitialCollectionView() {
        initialCollectionView.translatesAutoresizingMaskIntoConstraints = false
        initialCollectionView.backgroundColor = .white
        view.addSubview(initialCollectionView)

        // view constraints
        let viewHorizontalMargin = view.bounds.width * 0.05
        initialCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewHorizontalMargin).isActive = true
        initialCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -viewHorizontalMargin).isActive = true
        initialCollectionView.topAnchor.constraint(equalTo: plusImageView.bottomAnchor, constant: CGFloat(200)).isActive = true
        initialCollectionView.heightAnchor.constraint(equalToConstant: CGFloat(160)).isActive = true

        // collection layout
        initialCollectionViewFlowLayout.scrollDirection = .vertical
        initialCollectionViewFlowLayout.minimumLineSpacing = 10
        initialCollectionViewFlowLayout.minimumInteritemSpacing = 5

        // Sets up cell data
        initialCollectionView.dataSource = self
        initialCollectionView.delegate = self
        initialCollectionView.register(PinyinInitialCollectionViewCell.self, forCellWithReuseIdentifier:initialCellReuseIdentifier)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return initials.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: initialCellReuseIdentifier, for: indexPath) as! PinyinInitialCollectionViewCell
        let initial = initials[indexPath.item]
        cell.setCell(initial: initial)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 8 * 0.9
        let cellHeight = collectionView.bounds.height / 4 * 0.8
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for iter in collectionView.indexPathsForVisibleItems {
            let cell = collectionView.cellForItem(at: iter) as! PinyinInitialCollectionViewCell
            cell.unSelectCell()
        }
        let tappedCell = collectionView.cellForItem(at: indexPath) as! PinyinInitialCollectionViewCell
        tappedCell.selectCell()
        initialLabel.text = tappedCell.getCellLabel()
    }
}
