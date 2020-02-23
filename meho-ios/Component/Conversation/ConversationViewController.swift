//
//  ConversationViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 2/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants

    private let categoryCellReuseIdentifier = "Categories"
    private let dialogCellReuseIdentifier = "Dialogs"
    private let categoriesCollectionViewCellWidth = CGFloat(144)
    private let categoriesCollectionViewHeight = CGFloat(90)
    private let categoriesCollectionViewToDialogsCollectionViewMargin = CGFloat(15)
    private let categoriesCollectionViewLineSpacing = CGFloat(16)
    private let dialogsTitleLabelFontSize = CGFloat(16)
    private let dialogsTitleLabelTopMargin = CGFloat(17)
    private let dialogsCollectionViewCellHeight = CGFloat(105)
    private let dialogsCollectionViewLineSpacing = CGFloat(20)
    private let dialogsCollectionViewTopMargin = CGFloat(23)
    private let grayBackgroundViewBorderWidth = CGFloat(1)
    private let grayBackgroundViewCornerRadius = CGFloat(10)
    private let difficultyButtonFontSize = CGFloat(12)
    private let conversationTabBarItemImageName = "tabbar_conv_25pt"
    private let conversationTabBarItemSelectedImageName = "tabbar_conv_selected_25pt"

    // MARK: - Properties
    // MARK: UI
    private let categoriesCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var categoriesCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:categoriesCollectionViewFlowLayout)
    private let dialogsTitleLabel = UILabel.init(frame: .zero)
    private let dialogsCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var dialogsCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:dialogsCollectionViewFlowLayout)
    private let grayBackgroundView = UIView.init(frame: .zero)
    private let difficultyButton = UIButton.init(frame: .zero)
    // MARK: MODEL
    private var categories:[Category] = []
    private var dialogs:[Dialog] = []
    private let dataFecther = ConversationDataFetcher.init()
    private var currentCategory:Category? {
        didSet {
            if currentCategory != oldValue {
                self.fetchingDialogs()
            }
        }
    }
    private let allDifficulties = [Difficulty.beginner, Difficulty.intermediate, Difficulty.advanced]
    private var currentDifficulty = Difficulty.beginner {
        didSet {
            if currentDifficulty != oldValue {
                self.fetchingDialogs()
            }
        }
    }

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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let margins = view.layoutMarginsGuide

        // Sets up the categories collection view flow layout.
        categoriesCollectionViewFlowLayout.scrollDirection = .horizontal
        categoriesCollectionViewFlowLayout.minimumLineSpacing = categoriesCollectionViewLineSpacing
        let sectionLeadingInset = self.navigationController?.systemMinimumLayoutMargins.leading ?? 0
        let sectionTrailingInset = self.navigationController?.systemMinimumLayoutMargins.trailing ?? 0
        categoriesCollectionViewFlowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: sectionLeadingInset, bottom: 0, right: sectionTrailingInset)

        // Sets up the categories collection view.
        categoriesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoriesCollectionView.showsHorizontalScrollIndicator = false
        categoriesCollectionView.showsVerticalScrollIndicator = false
        categoriesCollectionView.backgroundColor = .white
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        categoriesCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier:categoryCellReuseIdentifier)
        self.view.addSubview(categoriesCollectionView)

        // Sets up the gray background view.
        grayBackgroundView.backgroundColor = .backgroundGray
        grayBackgroundView.layer.borderColor = UIColor.borderGray.cgColor
        grayBackgroundView.layer.borderWidth = grayBackgroundViewBorderWidth
        grayBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        grayBackgroundView.layer.cornerRadius = grayBackgroundViewCornerRadius
        grayBackgroundView.clipsToBounds = true
        grayBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(grayBackgroundView)

        // Sets up the dialogs title view.
        dialogsTitleLabel.textColor = .textDarkGray
        dialogsTitleLabel.text = NSLocalizedString("DialogsTitle", comment: "")
        dialogsTitleLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: dialogsTitleLabelFontSize)
        dialogsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        grayBackgroundView.addSubview(dialogsTitleLabel)

        // Sets up the difficulty button
        difficultyButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: difficultyButtonFontSize)
        difficultyButton.setTitle(currentDifficulty.title, for: .normal)
        let difficultyButtonImage = UIImage.init(systemName: "arrowtriangle.down.fill")
        difficultyButton.setImage(difficultyButtonImage, for: .normal)
        difficultyButton.setTitleColor(.textBlueGray, for: .normal)
        difficultyButton.translatesAutoresizingMaskIntoConstraints = false
        difficultyButton.tintColor = .textBlueGray
        difficultyButton.semanticContentAttribute = .forceRightToLeft
        difficultyButton.imageView?.contentMode = .scaleAspectFit
        difficultyButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        difficultyButton.addTarget(self, action: #selector(didTapDifficultyButton), for: .touchUpInside)
        grayBackgroundView.addSubview(difficultyButton)

        // Sets up the dialogs collection view flow layout.
        dialogsCollectionViewFlowLayout.scrollDirection = .vertical
        dialogsCollectionViewFlowLayout.minimumLineSpacing = dialogsCollectionViewLineSpacing

        // Sets up the categories collection view.
        dialogsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        dialogsCollectionView.showsHorizontalScrollIndicator = false
        dialogsCollectionView.showsVerticalScrollIndicator = true
        dialogsCollectionView.backgroundColor = .clear
        dialogsCollectionView.dataSource = self
        dialogsCollectionView.delegate = self
        dialogsCollectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier:dialogCellReuseIdentifier)
        grayBackgroundView.addSubview(dialogsCollectionView)

        // Sets up layout constrainsts.
        categoriesCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        categoriesCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        categoriesCollectionView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        categoriesCollectionView.heightAnchor.constraint(equalToConstant: categoriesCollectionViewHeight).isActive = true

        grayBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        grayBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        grayBackgroundView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant:categoriesCollectionViewToDialogsCollectionViewMargin).isActive = true
        grayBackgroundView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true

        dialogsTitleLabel.topAnchor.constraint(equalTo: grayBackgroundView.topAnchor, constant: dialogsTitleLabelTopMargin).isActive = true
        dialogsTitleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true

        difficultyButton.centerYAnchor.constraint(equalTo: dialogsTitleLabel.centerYAnchor).isActive = true
        difficultyButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

        dialogsCollectionView.topAnchor.constraint(equalTo: dialogsTitleLabel.bottomAnchor, constant: dialogsCollectionViewTopMargin).isActive = true
        dialogsCollectionView.bottomAnchor.constraint(equalTo: grayBackgroundView.bottomAnchor).isActive = true
        dialogsCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        dialogsCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

        dataFecther.fetchCategories { (categories, error) in
            if (error == nil && categories != nil) {
                self.categories = categories!
                DispatchQueue.main.async {
                    self.categoriesCollectionView.reloadData()
                }
                self.currentCategory = self.categories.first
            }
        }
    }


    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoriesCollectionView {
            return CGSize(width: categoriesCollectionViewCellWidth, height: categoriesCollectionViewHeight)
        }
        if collectionView == dialogsCollectionView {
            let width = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
            return CGSize(width: width, height: dialogsCollectionViewCellHeight)
        }
        
        return .zero
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return categories.count
        }
        if collectionView == dialogsCollectionView {
            return dialogs.count
        }
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellReuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
            let category = categories[indexPath.item]
            cell.setCategory(category: category)
            return cell
        }
        if collectionView == dialogsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dialogCellReuseIdentifier, for: indexPath) as! DialogCollectionViewCell
            let dialog = dialogs[indexPath.item]
            cell.setDialog(dialog: dialog)
            return cell
        }
        return UICollectionViewCell.init(frame: .zero)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
            self.currentCategory = categories[indexPath.item]
        }
    }

    // MARK: - Private
    func fetchingDialogs() {
        self.dataFecther.fetchDialogs(category: self.currentCategory?.title, difficulty: self.currentDifficulty.identifier.rawValue, completionHandler: { (dialogs, error) in
            if (error == nil && dialogs != nil) {
                self.dialogs = dialogs!
                DispatchQueue.main.async {
                    self.dialogsCollectionView.reloadData()
                }
            }
        })
    }

    @objc func didTapDifficultyButton() {
        let difficultyViewController = DifficultyViewController.init(allDifficulties: allDifficulties, currentDifficulty: currentDifficulty)
        let dialogViewController = DialogViewController.init(contentViewController: difficultyViewController)
        dialogViewController.modalPresentationStyle = .overFullScreen
        dialogViewController.modalTransitionStyle = .crossDissolve
        self.present(dialogViewController, animated: true, completion: nil)
    }
}
