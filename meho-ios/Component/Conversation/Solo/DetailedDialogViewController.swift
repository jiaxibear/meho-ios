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
    private var initialChapter: String?
    private let isExpression: Bool
    private var chaptersHavingRecordings: Set<String> = Set.init()

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
        isExpression = false
        self.dialog = dialog
        survivalPhraseCategoryIdentifier = nil
        displayScoreSwitch = nil
        super.init(nibName: nil, bundle: nil)
    }

    init(survivalPhraseCategoryIdentifier: String, title: String, initialChapter: String? = nil) {
        isExpression = true
        self.survivalPhraseCategoryIdentifier = survivalPhraseCategoryIdentifier
        self.initialChapter = initialChapter
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
                    return ScoredChapter.init(chapter: chapter, canBeSaved: true)
                })
                DispatchQueue.main.async {
                    self.hasAutoPlayedAudio = true
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
                            self.chaptersCollectionView.reloadData()
                            self.chaptersCollectionView.scrollToItem(at: IndexPath.init(item: initialChapterIndex, section: 0), at: .top, animated: false)
                        }
                    } else {
                        self.chaptersCollectionView.reloadData()
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
        let scoredChapter = scoredChapters[indexPath.item]
        if (indexPath.item == currentChapterIndex) {
            let expandedChapterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: expandedChapterCollectionViewCellReuseIdentifier, for: indexPath) as! ExpandedChapterCollectionViewCell
            expandedChapterCollectionViewCell.setScoredChapter(scoredChapter)
            expandedChapterCollectionViewCell.delegate = self
            return expandedChapterCollectionViewCell
        }
        let collapsedChapterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collapsedChapterCollectionViewCellReuseIdentifier, for: indexPath) as! CollapsedChapterCollectionViewCell
        collapsedChapterCollectionViewCell.setScoredChapter(scoredChapter)
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
        if isExpression && scoredChapter.isSaved == nil {
            updateExpressionSaveStatus(at: currentChapterIndex, at: previousCurrentChapterIndex)
        } else {
            reloadChapters(at: currentChapterIndex, at: previousCurrentChapterIndex)
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

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !hasAutoPlayedAudio && indexPath.item == 0, let expandedCell = cell as? ExpandedChapterCollectionViewCell{
            expandedCell.playAudio()
        }
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
        let emptyScoredChapters = scoredChapters.map { (scoredChapter) -> ScoredChapter in
            return ScoredChapter.init(chapter: scoredChapter.chapter)
        }
        let duoDetailerDialogViewController = DuoDetailedDialogViewController.init(scoredChapters: emptyScoredChapters, dialog: dialog)
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
        if let userId = AWSMobileClient.default().userSub, isExpression {
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
        guard let userId = AWSMobileClient.default().userSub else {
            return
        }
        let scoredChapterIndex = self.scoredChapters.firstIndex(where: { (scoredChapterInArray) -> Bool in
            return scoredChapter.chapter.content == scoredChapterInArray.chapter.content
        })
        if currentIsSaved {
            if let scoredChapterIndex = scoredChapterIndex {
                self.scoredChapters[scoredChapterIndex].isSaved = false
            }
            userDataFetcher.deleteUserItemSave(userId: userId, itemId: scoredChapter.chapter.identifier) { (unsaveSuccess, error) in
                if (error == nil && unsaveSuccess) {
                    self.view.makeToast(NSLocalizedString("removeSuccessfullyMessage", comment: ""))
                } else {
                    if let scoredChapterIndex = scoredChapterIndex {
                        self.scoredChapters[scoredChapterIndex].isSaved = true
                        self.chaptersCollectionView.reloadItems(at: [IndexPath.init(item: scoredChapterIndex, section: 0)])
                    }
                }
            }
        } else {
            if let scoredChapterIndex = scoredChapterIndex {
                self.scoredChapters[scoredChapterIndex].isSaved = true
            }
            userDataFetcher.createUserItemSave(userId: userId, itemId: scoredChapter.chapter.identifier, itemType: "EXPRESSION") { (saveSuccess, error) in
                if (error == nil && saveSuccess) {
                    self.view.makeToast(NSLocalizedString("saveSuccessfullyMessage", comment: ""))
                } else {
                    if let scoredChapterIndex = scoredChapterIndex {
                        self.scoredChapters[scoredChapterIndex].isSaved = false
                        self.chaptersCollectionView.reloadItems(at: [IndexPath.init(item: scoredChapterIndex, section: 0)])
                    }
                }
            }
        }
    }

    func expandedChapterCollectionViewCellDidTapAudioVisulizerInside(audioFileURL: URL, scoredChapter: ScoredChapter, scoreDetail: String) {
        guard let userId = AWSMobileClient.default().userSub else { return }
        let scoreD = Double(scoredChapter.score).rounded(.towardZero)
        if (survivalPhraseCategoryIdentifier != nil) {
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
            chaptersHavingRecordings.insert(scoredChapter.chapter.identifier)
            if chaptersHavingRecordings.count >= 3 {
                NotificationManager.displayNotificationSoftAsk(type: .talks, from: self)
            }
            displayEarnBambooToastIfNeeded()
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

    private func reloadChapters(at index: Int, at previousIndex: Int) {
        let currentIndexPath = IndexPath.init(item: index, section: 0)
        var indexPaths = [currentIndexPath]
        if previousIndex != -1 {
            indexPaths.append(IndexPath.init(item: previousIndex, section: 0))
        }
        UIView.performWithoutAnimation {
            self.chaptersCollectionView.reloadItems(at: indexPaths)
        }
        self.chaptersCollectionView.scrollToItem(at: currentIndexPath, at: .top, animated: true)
        if previousIndex != -1, let expandedChapterCollectionViewCell = self.chaptersCollectionView.cellForItem(at: currentIndexPath) as? ExpandedChapterCollectionViewCell {
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

    private func displayEarnBambooToastIfNeeded() {
        guard let dialog = dialog, chaptersHavingRecordings.count == scoredChapters.count else {
            return
        }

        var numberOfBamboos = 0
        switch (dialog.difficulty) {
        case .advanced:
            numberOfBamboos = 8
        case .beginner:
            numberOfBamboos = 4
        case .intermediate:
            numberOfBamboos = 6
        default:
            numberOfBamboos = 0
        }
        let toastFormat = NSLocalizedString("EarnBambooMessage", comment: "");
        let message = String.init(format: toastFormat, String(numberOfBamboos), NSLocalizedString("EarnBambooReasonSoloPractice", comment: ""))
        view.makeToast(message)
    }
}
