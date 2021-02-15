//
//  DetailedDialogViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 3/21/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAnalytics
import AWSMobileClient
import Amplify
import AmplifyPlugins

class DetailedDialogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DuoModeFooterCollectionResuableViewDelegate, MehoAnalytics, ExpandedChapterCollectionViewCellDelegate, NewsPlayingNow, NewsPlayingNowViewDelegate {
    // MARK: - Constants
    private let collapsedChapterCollectionViewCellReuseIdentifier = "collapsedChapterCollectionViewCellReuseIdentifier"
    private let expandedChapterCollectionViewCellReuseIdentifier = "expandedChapterCollectionViewCellReuseIdentifier"
    private let duoModeFooterCollectionResuableViewReuseIdentifier = "duoModeFooterCollectionResuableViewReuseIdentifier"

    // MARK: - Properties
    // MARK: Model
    private let conversationDataFetcher = ConversationDataFetcher.init()
    private let userDataFetcher = UserDataFetcher.shared
    private let expressionDataFetcher = ExpressionDataFetcher.init()
    private var scoredChapters: [ScoredChapter] = []
    private let dialog: Dialog!
    private let survivalPhraseCategoryIdentifier: String!
    private var currentChapterIndex = 0
    private var hasAutoPlayedAudio = false
    private let displayScoreSwitch: DisplayScoreSwitch?

    // MARK: MehoAnalytics
    var screenName: String {
        if survivalPhraseCategoryIdentifier != nil {
            return "p_meho_expressions_" + survivalPhraseCategoryIdentifier.lowercased()
        }
        if dialog != nil {
            return "p_meho_talks_single"
        }
        return ""
    }

    var screenClass: String {
        if survivalPhraseCategoryIdentifier != nil {
            return "p_meho_expressions_details"
        }
        if dialog != nil {
            return "p_meho_talks_single"
        }
        return ""
    }

    // MARK: UI
    private lazy var chaptersCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        chaptersCollectionViewFlowLayout.minimumLineSpacing = 0
        return chaptersCollectionViewFlowLayout
    }()

    private lazy var chaptersCollectionView: UICollectionView = {
        let chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: chaptersCollectionViewFlowLayout)
        chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chaptersCollectionView.backgroundColor = .white
        chaptersCollectionView.register(CollapsedChapterCollectionViewCell.self, forCellWithReuseIdentifier: collapsedChapterCollectionViewCellReuseIdentifier)
        chaptersCollectionView.register(ExpandedChapterCollectionViewCell.self, forCellWithReuseIdentifier: expandedChapterCollectionViewCellReuseIdentifier)
        if dialog != nil {
            chaptersCollectionView.register(DuoModeFooterCollectionResuableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: duoModeFooterCollectionResuableViewReuseIdentifier)
        }
        chaptersCollectionView.delegate = self
        chaptersCollectionView.dataSource = self
        return chaptersCollectionView
    }()

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

    init(dialog: Dialog) {
        self.dialog = dialog
        survivalPhraseCategoryIdentifier = nil
        displayScoreSwitch = nil
        super.init(nibName: nil, bundle: nil)
    }

    init(survivalPhraseCategoryIdentifier: String, title: String) {
        self.survivalPhraseCategoryIdentifier = survivalPhraseCategoryIdentifier
        dialog = nil
        displayScoreSwitch = DisplayScoreSwitch.init(frame: .zero)
        super.init(nibName: nil, bundle: nil)
        self.title = title
        displayScoreSwitch!.toggleSwitch.addTarget(self, action: #selector(displayScoreSwitchValueChanged), for: .valueChanged)
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white
        if title == nil {
            navigationController?.navigationBar.topItem?.title = ""
        }
        if displayScoreSwitch != nil {
            let displayScoreBarButtonItem = UIBarButtonItem.init(customView: displayScoreSwitch!)
            navigationItem.rightBarButtonItem = displayScoreBarButtonItem
        }
        if dialog != nil {
            conversationDataFetcher.fetchDetailedDialog(dialogID: dialog.identifier) { (dialog, error) in
                if (dialog != nil && error == nil) {
                    self.scoredChapters = dialog!.chapters.map({ (chapter) -> ScoredChapter in
                        return ScoredChapter.init(chapter: chapter)
                    })
                    DispatchQueue.main.async {
                        self.chaptersCollectionView.reloadData()
                        let audioSession = AVAudioSession.sharedInstance()
                        audioSession.requestRecordPermission { (allowed) in
                            // TODO: Add UI if not allowed.
                        }
                    }
                }
            }

            guard let userId = AWSMobileClient.default().userSub else { return }
            userDataFetcher.startItemProgressIfNeeded(userId: userId, itemId: dialog.identifier, itemType: "DIALOGUE")
        } else if survivalPhraseCategoryIdentifier != nil {
            expressionDataFetcher.fetchSurvivalPhrases(category: survivalPhraseCategoryIdentifier) { (result) in
                switch result {
                case .success(let chapters):
                self.scoredChapters = chapters.map({ (chapter) -> ScoredChapter in
                    return ScoredChapter.init(chapter: chapter, displaySaveButton: true)
                })
                DispatchQueue.main.async {
                    self.hasAutoPlayedAudio = true
                    self.chaptersCollectionView.reloadData()
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
        }

        view.addSubview(chaptersCollectionView)

        // Sets up layout constraints
        chaptersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chaptersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chaptersCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
        if survivalPhraseCategoryIdentifier != nil {
            for chapter in scoredChapters {
                chapter.contentTrackingID = UUID().uuidString
            }
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scoredChapters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.item == currentChapterIndex) {
            let scoredChapter = scoredChapters[indexPath.item]
            let expandedChapterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: expandedChapterCollectionViewCellReuseIdentifier, for: indexPath) as! ExpandedChapterCollectionViewCell
            expandedChapterCollectionViewCell.setScoredChapter(scoredChapters[currentChapterIndex], isSaveButtonHidden: !scoredChapter.isExpressionChapter)
            expandedChapterCollectionViewCell.delegate = self
            return expandedChapterCollectionViewCell
        }
        let collapsedChapterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collapsedChapterCollectionViewCellReuseIdentifier, for: indexPath) as! CollapsedChapterCollectionViewCell
        collapsedChapterCollectionViewCell.setScoredChapter(scoredChapters[indexPath.item])
        return collapsedChapterCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width;
        let chapter = scoredChapters[indexPath.item].chapter
        if (indexPath.item == currentChapterIndex) {
            let height = ExpandedChapterCollectionViewCell.cellHeight(with: width, chapter: chapter)
            return CGSize.init(width: width, height: height)
        }
        let height = CollapsedChapterCollectionViewCell.cellHeight(with: width, chapter: chapter)
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
        if scoredChapter.isExpressionChapter, let userId = AWSMobileClient.default().userSub {
            userDataFetcher.getUserItemSave (userId: userId, itemId: scoredChapter.chapter.identifier, completionHandler: { (isSaved, error) in
                guard error == nil else {
                    return
                }

                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        collectionView.reloadItems(at: [IndexPath.init(item: previousCurrentChapterIndex, section: 0), IndexPath.init(item: self.currentChapterIndex, section: 0)])
                    }
                    collectionView.scrollToItem(at: IndexPath.init(item: self.currentChapterIndex, section: 0), at: .top, animated: true)
                    if let expandedChapterCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ExpandedChapterCollectionViewCell {
                        expandedChapterCollectionViewCell.setInitialSaveButton(maybeIsSaved: isSaved)
                        expandedChapterCollectionViewCell.playAudio()
                    }
                }
            })
        } else {
            UIView.performWithoutAnimation {
                collectionView.reloadItems(at: [IndexPath.init(item: previousCurrentChapterIndex, section: 0), IndexPath.init(item: currentChapterIndex, section: 0)])
            }
            collectionView.scrollToItem(at: IndexPath.init(item: currentChapterIndex, section: 0), at: .top, animated: true)
            if let expandedChapterCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ExpandedChapterCollectionViewCell {
                expandedChapterCollectionViewCell.playAudio()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if scoredChapters.count == 0 || dialog == nil {
            return CGSize.zero
        }
        let height = DuoModeFooterCollectionResuableView.viewHeight
        return CGSize.init(width: 0, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            if let duoModeFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: duoModeFooterCollectionResuableViewReuseIdentifier, for: indexPath) as? DuoModeFooterCollectionResuableView {
                duoModeFooterView.delegate = self
                return duoModeFooterView
            }
        }
        return UICollectionReusableView.init(frame: .zero)
    }

    // MARK: - DuoModeFooterCollectionResuableViewDelegate
    func duoModeFooterCollectionResuableViewDidTapButton(_ view: DuoModeFooterCollectionResuableView) {
        let parameters = [
            MehoAnalyticsUtils.MehoAnalyticsParameterControlID: "p_meho_talks_solo-continue_with_duo",
            MehoAnalyticsUtils.MehoAnalyticsParameterControlName: "continue_with_duo",
            MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
            MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
        ]
        Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
        let duoDetailerDialogViewController = DuoDetailedDialogViewController.init(scoredChapters: scoredChapters, dialog: dialog)
        navigationController?.pushViewController(duoDetailerDialogViewController, animated: true)
    }

    // MARK: - ExpandedChapterCollectionViewCellDelegate
    func expandedChapterCollectionViewCellDidTapListenButton(scoredChapter: ScoredChapter) {
        let content: MehoContentAnalytics = dialog ?? scoredChapter
        Analytics.logContentAction(content: content, screenName: screenName, action: .play)
    }

    func expandedChapterCollectionViewCellDidTapReplayButton(scoredChapter: ScoredChapter) {
        let content: MehoContentAnalytics = dialog ?? scoredChapter
        Analytics.logContentAction(content: content, screenName: screenName, action: .replay)
    }

    func expandedChapterCollectionViewCellDidTapRecordButton(scoredChapter: ScoredChapter) {
        let content: MehoContentAnalytics = dialog ?? scoredChapter
        Analytics.logContentAction(content: content, screenName: screenName, action: .record)
        if let userId = AWSMobileClient.default().userSub, scoredChapter.isExpressionChapter {
            let expressionId = scoredChapter.chapter.identifier
            userDataFetcher.createUserItemCompleted(userId: userId, itemId: expressionId, itemType: "EXPRESSION") { (createCompletedSuccess, error) in
                if (error == nil && createCompletedSuccess) {
                    // do nothing
                    print("user:" + userId + ",expression:" + expressionId + " - added completed successful")
                } else {
                    print("user:" + userId + ",article:" + expressionId + " - added completed failed")
                }
            }
        }
    }

    func expandedChapterCollectionViewCellDidTapSpeedButton(scoredChapter: ScoredChapter) {
        let content: MehoContentAnalytics = dialog ?? scoredChapter
        Analytics.logContentAction(content: content, screenName: screenName, action: .adjustPlay)
    }

    func expandedChapterCollectionViewCellDidTapSaveButton(scoredChapter: ScoredChapter, currentIsSaved: Bool) {
        guard let userId = AWSMobileClient.default().userSub else { return }
        if currentIsSaved {
            userDataFetcher.deleteUserItemSave(userId: userId, itemId: scoredChapter.chapter.identifier) { (unsaveSuccess, error) in
                if (error == nil && unsaveSuccess) {
                    self.view.makeToast(NSLocalizedString("removeSuccessfullyMessage", comment: ""))

                }
            }
        } else {
            userDataFetcher.createUserItemSave(userId: userId, itemId: scoredChapter.chapter.identifier, itemType: "EXPRESSION") { (saveSuccess, error) in
                if (error == nil && saveSuccess) {
                    self.view.makeToast(NSLocalizedString("saveSuccessfullyMessage", comment: ""))
                }
            }
        }
    }

    func expandedChapterCollectionViewCellDidTapAudioVisulizerInside(audioFileURL: URL, scoredChapter: ScoredChapter, scoreDetail: String) {
        guard let userId = AWSMobileClient.default().userSub else { return }
        let scoreD = Double(scoredChapter.score).rounded(.towardZero)
        if (scoredChapter.isExpressionChapter) {
            userDataFetcher.createUserExpressionRecording(userId: userId, expressionId: scoredChapter.chapter.identifier, score: scoreD, scoreDetail: scoreDetail) { (maybeRecordingId, maybeError) in
                if let recordingId = maybeRecordingId, maybeError == nil {
                    self.uploadRecordingToS3(audioFileURL: audioFileURL, recordingId: recordingId)
                }
            }
        } else {
            userDataFetcher.createUserChapterRecording(userId: userId, chapterId: scoredChapter.chapter.identifier, mode: "SOLO", score: scoreD, scoreDetail: scoreDetail) { (maybeRecordingId, maybeError) in
                if let recordingId = maybeRecordingId, maybeError == nil {
                    self.uploadRecordingToS3(audioFileURL: audioFileURL, recordingId: recordingId)
                }
            }
        }

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
        var contentInset = chaptersCollectionView.contentInset
        contentInset.bottom = newsPlayingNowView.intrinsicContentSize.height
        chaptersCollectionView.contentInset = contentInset
        NSLayoutConstraint.activate([
            newsPlayingNowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsPlayingNowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsPlayingNowView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }

    // MARK: - NewsPlayingNowViewDelegate
    func didTapCancelButton() {
        var contentInset = chaptersCollectionView.contentInset
        contentInset.bottom = 0
        chaptersCollectionView.contentInset = contentInset
    }

    // MARK: - Private
    @objc
    func displayScoreSwitchValueChanged() {
        let shouldDisplayScore = displayScoreSwitch?.toggleSwitch.isOn
        if shouldDisplayScore != nil {
            let controlName = shouldDisplayScore! ? "toggle_score_on" : "toggle_score_off"
            let parameters = [
                MehoAnalyticsUtils.MehoAnalyticsParameterControlID: screenName,
                MehoAnalyticsUtils.MehoAnalyticsParameterControlName: controlName,
                MehoAnalyticsUtils.MehoAnalyticsParameterScreenName: screenName,
                MehoAnalyticsUtils.MehoAnalyticsParameterInteractionType: MehoAnalyticsParameterInteraction.shortPress.rawValue,
            ]
            Analytics.logEvent(MehoAnalyticsUtils.MehoAnalyticsEventInteractions, parameters:parameters)
            for scoredChapter in scoredChapters {
                scoredChapter.shouldDisplayScore = shouldDisplayScore!
                chaptersCollectionView.reloadData()
            }
        }
    }
}
