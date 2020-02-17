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
    private let categoriesCollectionViewHeight = CGFloat(105)
    private let categoriesCollectionViewToDialogsCollectionViewMargin = CGFloat(15)
    private let dialogsTitleLabelFontSize = CGFloat(16)
    private let dialogsTitleLabelTopMargin = CGFloat(17)
    private let dialogsCollectionViewCellHeight = CGFloat(105)
    private let dialogsCollectionViewLineSpacing = CGFloat(20)
    private let dialogsCollectionViewTopMargin = CGFloat(23)
    private let grayBackgroundViewBorderWidth = CGFloat(1)
    private let grayBackgroundViewCornerRadius = CGFloat(10)
    private let conversationTabBarItemImageName = "tabbar_conv_25pt"
    private let conversationTabBarItemSelectedImageName = "tabbar_conv_selected_25pt"

    // MARK: - Properties

    private let categoriesCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var categoriesCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:categoriesCollectionViewFlowLayout)
    private let dialogsTitleLabel = UILabel.init(frame: .zero)
    private let dialogsCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private lazy var dialogsCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout:dialogsCollectionViewFlowLayout)
    private let grayBackgroundView = UIView.init(frame: .zero)
    private var categories:[Category] = []
    private var dialogs:[Dialog] = []
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let margins = view.layoutMarginsGuide

        // Sets up the categories collection view flow layout.
        categoriesCollectionViewFlowLayout.scrollDirection = .horizontal

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
        categoriesCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        categoriesCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        categoriesCollectionView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        categoriesCollectionView.heightAnchor.constraint(equalToConstant: categoriesCollectionViewHeight).isActive = true

        grayBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        grayBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        grayBackgroundView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant:categoriesCollectionViewToDialogsCollectionViewMargin).isActive = true
        grayBackgroundView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true

        dialogsTitleLabel.topAnchor.constraint(equalTo: grayBackgroundView.topAnchor, constant: dialogsTitleLabelTopMargin).isActive = true
        dialogsTitleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true

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
            }
        }
        dataFecther.fetchDialogs { (dialogs, error) in
            if (error == nil && dialogs != nil) {
                self.dialogs = dialogs!
                DispatchQueue.main.async {
                    self.dialogsCollectionView.reloadData()
                }
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
}
