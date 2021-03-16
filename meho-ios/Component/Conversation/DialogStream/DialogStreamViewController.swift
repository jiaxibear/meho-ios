//
//  DialogStreamViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 3/18/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Toast_Swift
import AWSMobileClient
import FirebaseAnalytics

enum DialogStreamType {
    case mostPopular
    case featured
}

class DialogStreamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DialogStreamHeaderCollectionReusableViewDelegate, DifficultyViewControllerDelegate, DialogModeSelectionViewControllerDelegate, MehoAnalytics, NewsPlayingNow, NewsPlayingNowViewDelegate {

    // MARK: - Constants
    private let dialogCellReuseIdentifier = "dialogCellReuseIdentifier"
    private let dialogEmptyCellReuseIdentifier = "dialogEmptyCellReuseIdentifier"
    private let dialogStreamHeaderCellReuseIdentifier = "dialogStreamHeaderCellReuseIdentifier"
    private let dialogCollectionViewCellHeight = CGFloat(110)
    private let dialogCollectionViewCellLineSpacing = CGFloat(20)
    private let dialogCollectionViewSectionInset = UIEdgeInsets.init(top: 16, left: 0, bottom: 0, right: 0)
    private let trailingLeadingMargin = CGFloat(15)
    private let dialogCollectionViewSectionHeaderEstimatedHeight = CGFloat(29)

    // MARK: - Properties
    // MARK: UI
    private lazy var dialogsCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let dialogsCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        dialogsCollectionViewFlowLayout.minimumLineSpacing = dialogCollectionViewCellLineSpacing
        dialogsCollectionViewFlowLayout.sectionInset = dialogCollectionViewSectionInset
        return dialogsCollectionViewFlowLayout
    } ()

    private lazy var dialogsCollectionView: UICollectionView = {
        let dialogsCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: dialogsCollectionViewFlowLayout)
        dialogsCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: trailingLeadingMargin, bottom: 0, right: trailingLeadingMargin)
        dialogsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        dialogsCollectionView.backgroundColor = .white
        dialogsCollectionView.delegate = self
        dialogsCollectionView.dataSource = self
        dialogsCollectionView.register(DialogCollectionViewCell.self, forCellWithReuseIdentifier: dialogCellReuseIdentifier)
        dialogsCollectionView.register(DialogStreamEmptyCollectionViewCell.self, forCellWithReuseIdentifier: dialogEmptyCellReuseIdentifier)
        dialogsCollectionView.register(DialogStreamHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: dialogStreamHeaderCellReuseIdentifier)
        return dialogsCollectionView
    } ()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView.init(frame: .zero)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.backgroundColor = .white
        return loadingIndicator
    } ()

    // MARK: Data
    private let conversationDataFetcher = ConversationDataFetcher.init()
    private let userDataFetcher = UserDataFetcher.shared
    private var category: Category?
    private var dialogs: [Dialog]
    private var streamType: DialogStreamType?
    private var difficulty = Difficulty.all
    private let allDifficulties = [Difficulty.all, Difficulty.beginner, Difficulty.intermediate, Difficulty.advanced]

    // MARK: MehoAnalytics
    var screenName: String {
        if let title = category?.title {
            return "p_meho_talks_" + title.lowercased()
        } else if streamType == DialogStreamType.mostPopular {
            return "p_meho_talks_most_popular"
        } else if streamType == DialogStreamType.featured {
            return "p_meho_talks_featured"
        }
        return ""
    }

    let screenClass = "p_meho_talks_details"

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
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: false)
        fetchDialogs()

        view.addSubview(dialogsCollectionView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            dialogsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialogsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialogsCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            dialogsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.leadingAnchor.constraint(equalTo: dialogsCollectionView.leadingAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: dialogsCollectionView.trailingAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: dialogsCollectionView.topAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: dialogsCollectionView.bottomAnchor)
        ])
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
        if screenName.count > 0 {
            Analytics.logScreenViewEvent(viewController: self)
        }
        for index in dialogs.indices {
            dialogs[index].contentTrackingID = UUID().uuidString
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dialogs.count == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: dialogEmptyCellReuseIdentifier, for: indexPath)
        }
        let dialogCell = collectionView.dequeueReusableCell(withReuseIdentifier: dialogCellReuseIdentifier, for: indexPath) as! DialogCollectionViewCell
        let dialog = dialogs[indexPath.item]
        dialogCell.setDialog(dialog)
        return dialogCell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dialogs.count
        if count > 0 {
            return count
        } else {
            return 1
        }
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
                headerView.delegate = self
                return headerView
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = indexPath.item
        guard item < dialogs.count else {
            return
        }
        let dialog = dialogs[item]
        Analytics.logContentImpression(content: dialog, screenName: screenName)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 2 * trailingLeadingMargin
        if dialogs.count == 0 {
            return CGSize.init(width: width, height: DialogStreamEmptyCollectionViewCell.cellHeight())
        }
        return CGSize.init(width: width, height: dialogCollectionViewCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: 0, height: dialogCollectionViewSectionHeaderEstimatedHeight)
    }

    // MARK: - DialogStreamHeaderCollectionReusableViewDelegate
    func dialogStreamHeaderCollectionReusableViewDidTapDifficultyButton(_ view: DialogStreamHeaderCollectionReusableView) {
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_talks_category-view_difficulty",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_difficulty",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        let difficultyViewController = DifficultyViewController.init(allDifficulties: allDifficulties, currentDifficulty: difficulty)
        difficultyViewController.delegate = self
        let difficultyDialogViewController = DialogViewController.init(contentViewController: difficultyViewController)
        difficultyDialogViewController.modalPresentationStyle = .overFullScreen
        difficultyDialogViewController.modalTransitionStyle = .crossDissolve
        navigationController?.present(difficultyDialogViewController, animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = indexPath.item
        guard item < dialogs.count else {
            return
        }
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_talks_category-view_talk",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "view_talk",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        let dialog = dialogs[item]

        guard let userId = AWSMobileClient.default().userSub else { return }
        userDataFetcher.getUserItemSave (userId: userId, itemId: dialog.identifier, completionHandler: { (isSaved, error) in
            guard error == nil else {
                return
            }
            let dialogModeSelectionViewController = DialogModeSelectionViewController.init(dialog: dialog, maybeIsSaved: isSaved)
            dialogModeSelectionViewController.delegate = self
            let dialogViewController = DialogViewController.init(contentViewController: dialogModeSelectionViewController)
            dialogViewController.modalPresentationStyle = .overFullScreen
            dialogViewController.modalTransitionStyle = .crossDissolve

            DispatchQueue.main.async {
                self.navigationController?.present(dialogViewController, animated: true, completion: nil)
            }
        })
    }

    // MARK: - DifficultyViewControllerDelegate
    func didSelectDifficulty(_ diffculty: Difficulty) {
        self.difficulty = diffculty
        dismiss(animated: true) {
            self.fetchDialogs()
        }
    }

    // MARK: - DialogModeSelectionViewControllerDelegate
    func dialogModeSelectionViewControllerDidTapDuoRolePlayButton(dialog: Dialog) {
        dismiss(animated: true) {
            let duoDetailedDialogViewController = DuoDetailedDialogViewController.init(dialog: dialog)
            self.navigationController?.pushViewController(duoDetailedDialogViewController, animated: true)
        }
    }

    func dialogModeSelectionViewControllerDidTapSoloPracticeButton(dialog: Dialog) {
        dismiss(animated: true) {
            let detailedDialogViewController = DetailedDialogViewController.init(dialog: dialog)
            self.navigationController?.pushViewController(detailedDialogViewController, animated: true)
        }
    }

    func dialogModeSelectionViewControllerDidTapSaveButton(isSaved: Bool) {
        if isSaved {
            view.makeToast(NSLocalizedString("saveSuccessfullyMessage", comment: ""))
        } else {
            view.makeToast(NSLocalizedString("removeSuccessfullyMessage", comment: ""))
        }
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }
        newsPlayingNowView.delegate = self

        view.addSubview(newsPlayingNowView)
        var contentInset = dialogsCollectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        dialogsCollectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        var contentInset = dialogsCollectionView.contentInset
        contentInset.bottom = 0
        dialogsCollectionView.contentInset = contentInset
    }

    // MARK: - Private
    func fetchDialogs() {
        dialogsCollectionView.isHidden = true
        loadingIndicator.startAnimating()
        let difficultyString = difficulty == .all ? nil : difficulty.identifier.rawValue
        if let category = category {
            let categoryID = category.identifier
            conversationDataFetcher.fetchDialoguesOfCategory(categoryID: categoryID) { (dialogs, error) in
                DispatchQueue.main.async {
                    self.dialogsCollectionView.isHidden = false
                    self.loadingIndicator.stopAnimating()
                }
                if let dialogs = dialogs {
                    if self.difficulty == .all {
                        self.dialogs = dialogs
                    } else {
                        self.dialogs = dialogs.filter({ (dialog) -> Bool in
                            dialog.difficulty == self.difficulty
                        })
                    }
                    DispatchQueue.main.async {
                        self.dialogsCollectionView.reloadData()
                    }
                }
            }
        } else {
            switch streamType {
            case .mostPopular:
                conversationDataFetcher.fetchMostPopularDialogs(difficulty: difficultyString, completionHandler: { (dialogs, error) in
                    DispatchQueue.main.async {
                        self.dialogsCollectionView.isHidden = false
                        self.loadingIndicator.stopAnimating()
                    }
                    if let dialogs = dialogs {
                        if difficultyString == nil {
                            self.dialogs = dialogs
                        } else {
                            self.dialogs = dialogs.filter({ (dialog) -> Bool in
                                dialog.difficulty == self.difficulty
                            })
                        }
                        DispatchQueue.main.async {
                            self.dialogsCollectionView.reloadData()
                        }
                    }
                })
                break
            case .featured:
                conversationDataFetcher.fetchFeaturedDialogs(difficulty: difficultyString, completionHandler: { (dialogs, error) in
                    DispatchQueue.main.async {
                        self.dialogsCollectionView.isHidden = false
                        self.loadingIndicator.stopAnimating()
                    }
                    if let dialogs = dialogs {
                        if difficultyString == nil {
                            self.dialogs = dialogs
                        } else {
                            self.dialogs = dialogs.filter({ (dialog) -> Bool in
                                dialog.difficulty == self.difficulty
                            })
                        }
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
    }
}
