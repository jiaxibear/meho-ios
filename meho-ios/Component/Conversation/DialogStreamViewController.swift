//
//  DialogStreamViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 3/18/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

enum DialogStreamType {
    case mostPopular
    case featured
}

class DialogStreamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Constants
    private let dialogCellReuseIdentifier = "dialogCellReuseIdentifier"
    private let dialogStreamHeaderCellReuseIdentifier = "dialogStreamHeaderCellReuseIdentifier"
    private let dialogCollectionViewCellHeight = CGFloat(110)
    private let dialogCollectionViewCellLineSpacing = CGFloat(20)
    private let dialogCollectionViewSectionInset = UIEdgeInsets.init(top: 16, left: 0, bottom: 0, right: 0)
    private let trailingLeadingMargin = CGFloat(15)
    private let dialogCollectionViewSectionHeaderEstimatedHeight = CGFloat(29)

    // MARK: - Properties
    private let dialogsCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
    private let conversationDataFetcher = ConversationDataFetcher.init()
    private lazy var dialogsCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: dialogsCollectionViewFlowLayout)
    private var category: Category?
    private var dialogs: [Dialog]
    private var streamType: DialogStreamType?
    private var difficulty: Difficulty?

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

    init(streamType: DialogStreamType) {
        self.streamType = streamType
        self.dialogs = []
        super.init(nibName: nil, bundle: nil)
    }

    init(category: Category) {
        self.category = category
        self.dialogs = []
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        if category != nil {
            difficulty = .beginner
            conversationDataFetcher.fetchDialogs(category: category!.identifier, difficulty: nil) { (dialogs, error) in
                if error == nil && dialogs != nil {
                    self.dialogs = dialogs!
                    DispatchQueue.main.async {
                        self.dialogsCollectionView.reloadData()
                    }
                }
            }
        } else {
            switch streamType {
            case .mostPopular:
                conversationDataFetcher.fetchMostPopularDialogs(completionHandler: { (dialogs, error) in
                    if error == nil && dialogs != nil {
                        self.dialogs = dialogs!
                        DispatchQueue.main.async {
                            self.dialogsCollectionView.reloadData()
                        }
                    }
                })
                break
            case .featured:
                conversationDataFetcher.fetchFeaturedDialogs(completionHandler: { (dialogs, error) in
                    if error == nil && dialogs != nil {
                        self.dialogs = dialogs!
                        DispatchQueue.main.async {
                            self.dialogsCollectionView.reloadData()
                        }
                    }
                })
                break
            case .none:
                break
            }
        }

        dialogsCollectionViewFlowLayout.minimumLineSpacing = dialogCollectionViewCellLineSpacing
        dialogsCollectionViewFlowLayout.sectionInset = dialogCollectionViewSectionInset
        dialogsCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: trailingLeadingMargin, bottom: 0, right: trailingLeadingMargin)
        dialogsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        dialogsCollectionView.backgroundColor = .white
        dialogsCollectionView.delegate = self
        dialogsCollectionView.dataSource = self
        dialogsCollectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier: dialogCellReuseIdentifier)
        dialogsCollectionView.register(DialogStreamHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: dialogStreamHeaderCellReuseIdentifier)
        view.addSubview(dialogsCollectionView)

        dialogsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dialogsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dialogsCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dialogsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dialogCell = collectionView.dequeueReusableCell(withReuseIdentifier: dialogCellReuseIdentifier, for: indexPath) as! DialogCollectionViewCell
        let dialog = dialogs[indexPath.item]
        dialogCell.setDialog(dialog)
        return dialogCell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dialogs.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: dialogStreamHeaderCellReuseIdentifier, for: indexPath) as? DialogStreamHeaderCollectionReusableView {
                if category != nil {
                    headerView.setTitle(category!.title)
                } else {
                    switch streamType {
                    case .featured:
                        headerView.setTitle(NSLocalizedString("FeaturedTitle", comment: ""))
                        break
                    case .mostPopular:
                        headerView.setTitle(NSLocalizedString("MostPopularTitle", comment: ""))
                        break
                    case .none:
                        break
                    }
                }
                headerView.setDifficulty(difficulty)
                return headerView
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.bounds.width - 2 * trailingLeadingMargin, height: dialogCollectionViewCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: 0, height: dialogCollectionViewSectionHeaderEstimatedHeight)
    }
}
