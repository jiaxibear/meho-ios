
//
//  MustKnowPhraseViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 11/12/21.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAnalytics
import AWSMobileClient
import Amplify
import AmplifyPlugins

class MustKnowPhraseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MehoAnalytics, NewsPlayingNow, NewsPlayingNowViewDelegate {
    // MARK: - Constants
    private let mustKnowPhraseCollectionViewCellReuseIdentifier = "mustKnowPhraseCollectionViewCellReuseIdentifier"
    private let mustKnowPhraseCollectionViewContentLeadingTopInset = CGFloat(6)
    private let mustKnowPhraseCollectionViewContentLeadingTrailingMargin = CGFloat(16)
    private let mustKnowPhraseCollectionViewMinimumLineSpacing = CGFloat(20)

    // MARK: - Properties
    // MARK: Model
    private let userDataFetcher = UserDataFetcher.shared
    private let expressionDataFetcher = ExpressionDataFetcher.init()
    private var scoredChapters: [ScoredChapter] = []
    private let survivalPhraseCategoryIdentifier: String
    private var currentChapterIndex = 0
    private var chaptersHavingRecordings: Set<String> = Set.init()
    private var initialChapter: String?

    // MARK: MehoAnalytics
    var screenName: String {
        return "p_meho_expressions_" + survivalPhraseCategoryIdentifier.lowercased()
    }

    var screenClass: String {
        return "p_meho_expressions_details"
    }

    // MARK: UI
    private lazy var displayScoreSwitch: DisplayScoreSwitch = {
        let displayScoreSwitch = DisplayScoreSwitch.init(frame: .zero)
        displayScoreSwitch.toggleSwitch.addTarget(self, action: #selector(displayScoreSwitchValueChanged), for: .valueChanged)
        return displayScoreSwitch
    } ()

    private lazy var mustKnowPhraseCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let mustKnowPhraseCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        mustKnowPhraseCollectionViewFlowLayout.minimumLineSpacing = mustKnowPhraseCollectionViewMinimumLineSpacing
        return mustKnowPhraseCollectionViewFlowLayout
    } ()

    private lazy var mustKnowPhraseCollectionView: UICollectionView = {
        let mustKnowPhraseCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: mustKnowPhraseCollectionViewFlowLayout)
        mustKnowPhraseCollectionView.translatesAutoresizingMaskIntoConstraints = false
        mustKnowPhraseCollectionView.backgroundColor = .white
        mustKnowPhraseCollectionView.register(MustKnowPhraseCollectionViewCell.self, forCellWithReuseIdentifier: mustKnowPhraseCollectionViewCellReuseIdentifier)
        mustKnowPhraseCollectionView.delegate = self
        mustKnowPhraseCollectionView.dataSource = self
        mustKnowPhraseCollectionView.contentInset = UIEdgeInsets.init(top: mustKnowPhraseCollectionViewContentLeadingTopInset, left: 0, bottom: 0, right: 0)
        return mustKnowPhraseCollectionView
    } ()

    // MARK: - Init
    init() {
        fatalError("Use init(dialogID: String)")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(dialogID: String)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(dialogID: String)")
    }

    init(survivalPhraseCategoryIdentifier: String, title: String, initialChapter: String? = nil) {
        self.survivalPhraseCategoryIdentifier = survivalPhraseCategoryIdentifier
        self.initialChapter = initialChapter
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white
        let displayScoreBarButtonItem = UIBarButtonItem.init(customView: displayScoreSwitch)
        navigationItem.rightBarButtonItem = displayScoreBarButtonItem
        expressionDataFetcher.fetchSurvivalPhrases(category: survivalPhraseCategoryIdentifier) { (result) in
            switch result {
            case .success(let chapters):
                self.scoredChapters = chapters.map({ (chapter) -> ScoredChapter in
                    return ScoredChapter.init(chapter: chapter, canBeSaved: true)
                })
                DispatchQueue.main.async {
                    if let initialChapter = self.initialChapter {
                        var initialChapterIndex = -1
                        for (index, element) in self.scoredChapters.enumerated() {
                            if element.chapter.content == initialChapter {
                                initialChapterIndex = index
                                break
                            }
                        }
                        if initialChapterIndex != -1 {
                            self.currentChapterIndex = initialChapterIndex
                            self.mustKnowPhraseCollectionView.reloadData()
                            self.mustKnowPhraseCollectionView.scrollToItem(at: IndexPath.init(item: initialChapterIndex, section: 0), at: .top, animated: false)
                        }
                    } else {
                        self.mustKnowPhraseCollectionView.reloadData()
                    }
                    self.updateExpressionSaveStatus(at: self.currentChapterIndex, at: -1)
                    let audioSession = AVAudioSession.sharedInstance()
                    audioSession.requestRecordPermission { (allowed) in
                        // TODO: Add UI if not allowed.
                    }
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }

        view.addSubview(mustKnowPhraseCollectionView)

        // Sets up layout constraints
        mustKnowPhraseCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mustKnowPhraseCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mustKnowPhraseCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        mustKnowPhraseCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
        if screenClass.count > 0 && screenName.count > 0 {
            Analytics.logScreenViewEvent(viewController: self)
        }
        for chapter in scoredChapters {
            chapter.contentTrackingID = UUID().uuidString
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scoredChapters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let scoredChapter = scoredChapters[indexPath.item]
        if (indexPath.item == currentChapterIndex) {

        }
        let mustKnowPhraseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: mustKnowPhraseCollectionViewCellReuseIdentifier, for: indexPath) as! MustKnowPhraseCollectionViewCell
        mustKnowPhraseCollectionViewCell.setScoredChapter(scoredChapter)
        return mustKnowPhraseCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 2 * mustKnowPhraseCollectionViewContentLeadingTrailingMargin;
        let chapter = scoredChapters[indexPath.item].chapter
        let height = MustKnowPhraseCollectionViewCell.cellHeight(with: width, chapter: chapter)
        return CGSize.init(width: width, height: height)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chapterIndex = indexPath.item
        if chapterIndex == currentChapterIndex {
            return
        }
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "expand_phrase",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        let previousCurrentChapterIndex = currentChapterIndex
        currentChapterIndex = indexPath.item

        let scoredChapter = scoredChapters[currentChapterIndex]
        if scoredChapter.isSaved == nil {
            updateExpressionSaveStatus(at: currentChapterIndex, at: previousCurrentChapterIndex)
        } else {
            reloadChapters(at: currentChapterIndex, at: previousCurrentChapterIndex)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if scoredChapters.count == 0 {
            return CGSize.zero
        }
        let height = DuoModeFooterCollectionResuableView.viewHeight
        return CGSize.init(width: 0, height: height)
    }

    func uploadRecordingToS3(audioFileURL: URL, recordingId: String) {
        let options = StorageUploadFileRequest.Options(accessLevel: .private)
        Amplify.Storage.uploadFile(
            key: recordingId + ".caf",
            local: audioFileURL,
            options: options,
            resultListener: { event in
                switch event {
                case .success(_):
                    break
                case let .failure(storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
        )
    }

    // MARK: - NewsPlayingNow
    func displayNewsPlayingNowView(_ newsPlayingNowView: NewsPlayingNowView) {
        if newsPlayingNowView.superview != nil {
            newsPlayingNowView.removeFromSuperview()
        }
        newsPlayingNowView.delegate = self

        view.addSubview(newsPlayingNowView)
        var contentInset = mustKnowPhraseCollectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        mustKnowPhraseCollectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        var contentInset = mustKnowPhraseCollectionView.contentInset
        contentInset.bottom = 0
        mustKnowPhraseCollectionView.contentInset = contentInset
    }

    // MARK: - Private
    @objc
    func displayScoreSwitchValueChanged() {
        let shouldDisplayScore = displayScoreSwitch.toggleSwitch.isOn
        let controlName = shouldDisplayScore ? "toggle_score_on" : "toggle_score_off"
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: controlName,
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        for scoredChapter in scoredChapters {
            scoredChapter.shouldDisplayScore = shouldDisplayScore
            mustKnowPhraseCollectionView.reloadData()
        }
    }

    private func reloadChapters(at index: Int, at previousIndex: Int) {
        let currentIndexPath = IndexPath.init(item: index, section: 0)
        var indexPaths = [currentIndexPath]
        if previousIndex != -1 {
            indexPaths.append(IndexPath.init(item: previousIndex, section: 0))
        }
        UIView.performWithoutAnimation {
            self.mustKnowPhraseCollectionView.reloadItems(at: indexPaths)
        }
        self.mustKnowPhraseCollectionView.scrollToItem(at: currentIndexPath, at: .top, animated: true)
        if previousIndex != -1, let expandedChapterCollectionViewCell = self.mustKnowPhraseCollectionView.cellForItem(at: currentIndexPath) as? ExpandedChapterCollectionViewCell {
            expandedChapterCollectionViewCell.playAudio()
        }
    }

    private func updateExpressionSaveStatus(at index: Int, at previousIndex: Int) {
        guard let userID = AWSMobileClient.default().userSub, index < scoredChapters.count else {
            return
        }
        let scoredChapter = scoredChapters[index]
        userDataFetcher.getUserItemSave (userId: userID, itemId: scoredChapter.chapter.identifier, completionHandler: { (isSaved, error) in
            guard error == nil else {
                return
            }

            self.scoredChapters[index].isSaved = isSaved
            DispatchQueue.main.async {
                self.reloadChapters(at: index, at: previousIndex)
            }
        })
    }
}
