
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

class MustKnowPhraseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MehoAnalytics, NewsPlayingNow, NewsPlayingNowViewDelegate, AudioVisualizerViewDelegte, MustKnowPhraseCollectionViewCellDelegate {
    // MARK: - Constants
    private let mustKnowPhraseCollectionViewCellReuseIdentifier = "mustKnowPhraseCollectionViewCellReuseIdentifier"
    private let mustKnowPhraseCollectionViewContentLeadingTopInset = CGFloat(6)
    private let mustKnowPhraseCollectionViewContentLeadingTrailingMargin = CGFloat(16)
    private let mustKnowPhraseCollectionViewMinimumLineSpacing = CGFloat(20)
    private let actionLabelFontSize = CGFloat(14)
    private let recordButtonNormalImageName = "conversation_microphone_inactive"
    private let listenButtonNormalImageName = "conversation_headset_inactive"
    private let replayButtonNormalImageName = "conversation_play_inactive"
    private let recordButtonSelectedImageName = "conversation_microphone_active"
    private let listenButtonSelectedImageName = "conversation_headset_active"
    private let replayButtonSelectedImageName = "conversation_play_active"
    private let replayButtonDisabledImageName = "conversation_play_disabled"
    private let recordButtonDisabledImageName = "conversation_microphone_disabled"
    private let recordButtonSize = CGFloat(70)
    private let listenButtonSize = CGFloat(50)
    private let replayButtonSize = CGFloat(50)
    private let buttonsStackViewSpacing = CGFloat(48)
    private let actionLabelTopBottomMargin = CGFloat(20)
    private let buttonsStackViewBottomMargin = CGFloat(40)
    private let audioDBLowerLimit = Float(-30)

    // MARK: - Properties
    // MARK: Model
    private let userDataFetcher = UserDataFetcher.shared
    private let expressionDataFetcher = ExpressionDataFetcher.init()
    private var scoredChapters: [ScoredChapter] = []
    private let survivalPhraseCategoryIdentifier: String
    private var player: AVPlayer?
    private var currentChapterIndex = 0 {
        didSet {

        }
    }
    private var currentScoredChapter: ScoredChapter {
        return scoredChapters[currentChapterIndex]
    }

    private var currentAudioFileURL: URL {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
        isDirectory: true)
        let identifier = currentScoredChapter.chapter.identifier
        let audioFileName = "\(identifier).caf"
        let audioFileURL = temporaryDirectoryURL.appendingPathComponent(audioFileName)
        return audioFileURL
    }

    private var chaptersHavingRecordings: Set<String> = Set.init()
    private var initialChapter: String?
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private let contentEvaluator = ContentEvaluator.init()

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

    private lazy var actionLabel: UILabel = {
        let actionLabel = UILabel.init(frame: .zero)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.textColor = .textBlueGray
        let actionLabelFontDescriptor = UIFont.systemFont(ofSize: actionLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        actionLabel.font = UIFont.init(descriptor: actionLabelFontDescriptor!, size:actionLabelFontSize)
        actionLabel.numberOfLines = 1
        actionLabel.textAlignment = .center
        return actionLabel
    } ()

    private lazy var replayButton: UIButton = {
        let replayButton = UIButton.init(frame: .zero)
        replayButton.translatesAutoresizingMaskIntoConstraints = false
        let replayButtonNormalImage = UIImage.init(named: replayButtonNormalImageName)
        replayButton.setImage(replayButtonNormalImage, for: .normal)
        let replayButtonDisabledImage = UIImage.init(named: replayButtonDisabledImageName)
        replayButton.setImage(replayButtonDisabledImage, for: .disabled)
        let replayButtonSelectedImageName = UIImage.init(named: replayButtonSelectedImageName)
        replayButton.setImage(replayButtonSelectedImageName, for: .selected)
        replayButton.clipsToBounds = true
        replayButton.layer.cornerRadius = replayButtonSize / 2
        replayButton.addTarget(self, action: #selector(didTapReplayButton), for: .touchUpInside)
        return replayButton
    } ()

    private lazy var recordButton: UIButton = {
        let recordButton = UIButton.init(frame: .zero)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        let recordButtonNormalImage = UIImage.init(named: recordButtonNormalImageName)
        recordButton.setImage(recordButtonNormalImage, for: .normal)
        let recordButtonDisabledImage = UIImage.init(named: recordButtonDisabledImageName)
        recordButton.setImage(recordButtonDisabledImage, for: .disabled)
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = recordButtonSize / 2
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        return recordButton
    } ()

    private lazy var listenButton: UIButton = {
        let listenButton = UIButton.init(frame: .zero)
        listenButton.translatesAutoresizingMaskIntoConstraints = false
        let listenButtonNormalImage = UIImage.init(named: listenButtonNormalImageName)
        listenButton.setImage(listenButtonNormalImage, for: .normal)
        let listenButtonEnabledImage = UIImage.init(named: listenButtonSelectedImageName)
        listenButton.setImage(listenButtonEnabledImage, for: .selected)
        listenButton.clipsToBounds = true
        listenButton.layer.cornerRadius = listenButtonSize / 2
        listenButton.addTarget(self, action: #selector(didTapListenButton), for: .touchUpInside)
        return listenButton
    } ()

    private lazy var audioVisualizerView: AudioVisualizerView = {
        let audioVisualizerView = AudioVisualizerView.init(frame: .zero)
        audioVisualizerView.isHidden = true
        audioVisualizerView.translatesAutoresizingMaskIntoConstraints = false
        audioVisualizerView.delegate = self
        return audioVisualizerView
    } ()

    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView.init(arrangedSubviews: [listenButton, recordButton, replayButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.alignment = .center
        buttonsStackView.distribution = .fill
        buttonsStackView.spacing = buttonsStackViewSpacing
        return buttonsStackView
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
                        self.currentChapterIndex = 0
                        self.mustKnowPhraseCollectionView.reloadData()
                    }
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
        view.addSubview(actionLabel)
        view.addSubview(buttonsStackView)
        view.addSubview(audioVisualizerView)

        let buttonsStackViewWidth = recordButtonSize + listenButtonSize + replayButtonSize + 2 * buttonsStackViewSpacing
        // Sets up layout constraints
        NSLayoutConstraint.activate([
            mustKnowPhraseCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mustKnowPhraseCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mustKnowPhraseCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            mustKnowPhraseCollectionView.bottomAnchor.constraint(equalTo: actionLabel.topAnchor, constant: -actionLabelTopBottomMargin),

            actionLabel.leadingAnchor.constraint(equalTo: mustKnowPhraseCollectionView.leadingAnchor),
            actionLabel.trailingAnchor.constraint(equalTo: mustKnowPhraseCollectionView.trailingAnchor),
            actionLabel.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -actionLabelTopBottomMargin),

            buttonsStackView.heightAnchor.constraint(equalToConstant: recordButtonSize),
            buttonsStackView.widthAnchor.constraint(equalToConstant: buttonsStackViewWidth),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -buttonsStackViewBottomMargin),
            buttonsStackView.centerXAnchor.constraint(equalTo: actionLabel.centerXAnchor),

            audioVisualizerView.leadingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor),
            audioVisualizerView.trailingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor),
            audioVisualizerView.topAnchor.constraint(equalTo: buttonsStackView.topAnchor),
            audioVisualizerView.bottomAnchor.constraint(equalTo: buttonsStackView.bottomAnchor),

            replayButton.heightAnchor.constraint(equalToConstant: replayButtonSize),
            replayButton.widthAnchor.constraint(equalToConstant: replayButtonSize),

            listenButton.heightAnchor.constraint(equalToConstant: listenButtonSize),
            listenButton.widthAnchor.constraint(equalToConstant: listenButtonSize),

            recordButton.heightAnchor.constraint(equalToConstant: recordButtonSize),
            recordButton.widthAnchor.constraint(equalToConstant: recordButtonSize),
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
        let mustKnowPhraseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: mustKnowPhraseCollectionViewCellReuseIdentifier, for: indexPath) as! MustKnowPhraseCollectionViewCell
        mustKnowPhraseCollectionViewCell.setScoredChapter(scoredChapter, isSelected: indexPath.item == currentChapterIndex)
        mustKnowPhraseCollectionViewCell.delegate = self
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
        reloadChapters(at: currentChapterIndex, at: previousCurrentChapterIndex)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = indexPath.item
        updateExpressionSaveStatus(at: item)
    }

    // MARK: - AudioVisualizerViewDelegte
    func audioVisualizerViewDidTapInside(_ audioVisualizerView: AudioVisualizerView) {
        buttonsStackView.isHidden = false
        audioVisualizerView.isHidden = true
        timer?.invalidate()
        timer = nil
        recordButton.isSelected = false
        actionLabel.isHidden = true
        audioRecorder?.stop()
        let audioFileURL = currentAudioFileURL
        replayButton.isEnabled = FileManager.default.fileExists(atPath: audioFileURL.path)
        let content = currentScoredChapter.chapter.content
        contentEvaluator.evaluate(content: content, audioFileURL: audioFileURL) { (result) in
            switch result {
            case .success(let contentEvaluationResult):
                let suggestedScore = contentEvaluationResult.score
                self.currentScoredChapter.score = suggestedScore
                let scoredContent = contentEvaluationResult.scoredContent
                self.currentScoredChapter.scoredContent = scoredContent
                self.actionLabel.isHidden = false
                if self.displayScoreSwitch.toggleSwitch.isOn {
                    self.actionLabel.text = NSLocalizedString("ReplayPromptActionText", comment: "")
                } else {
                    self.actionLabel.text = NSLocalizedString("ReplayWithoutScorePromptActionText", comment: "")
                }
                self.mustKnowPhraseCollectionView.reloadItems(at: [IndexPath.init(item: self.currentChapterIndex, section: 0)])
                guard let userID = AWSMobileClient.default().userSub else {
                    return
                }
                let scoreD = Double(self.currentScoredChapter.score).rounded(.towardZero)
                self.userDataFetcher.createUserExpressionRecording(userId: userID, expressionId: self.currentScoredChapter.chapter.identifier, score: scoreD, scoreDetail: contentEvaluationResult.scoreDetail) { (maybeRecordingId, maybeError) in
                    if let recordingId = maybeRecordingId, maybeError == nil {
                        self.uploadRecordingToS3(audioFileURL: audioFileURL, recordingId: recordingId)
                    }
                }
                break
            case .failure(let error):
                self.recordButton.isSelected = false
                self.actionLabel.isHidden = false
                self.actionLabel.text = NSLocalizedString("RecordPromptActionText", comment: "")
                print(error.localizedDescription)
                break
            }
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

    // MARK: - MustKnowPhraseCollectionViewCellDelegate
    func mustKnowPhraseCollectionViewCellDidTapSaveButton(scoredChapter: ScoredChapter, currentIsSaved: Bool) {
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
                        self.mustKnowPhraseCollectionView.reloadItems(at: [IndexPath.init(item: scoredChapterIndex, section: 0)])
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
                        self.mustKnowPhraseCollectionView.reloadItems(at: [IndexPath.init(item: scoredChapterIndex, section: 0)])
                    }
                }
            }
        }
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
    }

    private func updateExpressionSaveStatus(at index: Int) {
        guard let userID = AWSMobileClient.default().userSub, index < scoredChapters.count else {
            return
        }
        let scoredChapter = scoredChapters[index]
        if scoredChapter.isSaved != nil {
            return
        }
        userDataFetcher.getUserItemSave (userId: userID, itemId: scoredChapter.chapter.identifier, completionHandler: { (isSaved, error) in
            guard error == nil else {
                return
            }

            self.scoredChapters[index].isSaved = isSaved
            DispatchQueue.main.async {
                if let cell = self.mustKnowPhraseCollectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as? MustKnowPhraseCollectionViewCell {
                    cell.updateSaveStatus(scoredChapter: self.scoredChapters[index])
                }
            }
        })
    }

    @objc func didTapListenButton() {
        let scoredChapter = scoredChapters[currentChapterIndex]
        guard let audioKey = scoredChapter.chapter.contentAudioKey else {
            return
        }
        Amplify.Storage.getURL(key: audioKey) { event in
            switch event {
            case let .success(url):
                DispatchQueue.main.async {
                    self.listenButton.isSelected = true
                    self.replayButton.isSelected = false
                    self.recordButton.isSelected = false
                    NewsAudioPlayer.shared.pauseAudio()
                    let playerItem = AVPlayerItem.init(url: url)
                    playerItem.audioTimePitchAlgorithm = .spectral
                    let player = AVPlayer.init(playerItem: playerItem)
                    player.play()
                    NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                    self.player = player
                    self.actionLabel.text = NSLocalizedString("ListenActionText", comment: "")
                    self.actionLabel.isHidden = false
                    Analytics.logContentAction(content: scoredChapter, screenName: self.screenName, action: .play)
                }
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }

    @objc func didTapReplayButton() {
        if FileManager.default.fileExists(atPath: currentAudioFileURL.path) {
            listenButton.isSelected = false
            replayButton.isSelected = true
            recordButton.isSelected = false
            NewsAudioPlayer.shared.pauseAudio()
            let playerItem = AVPlayerItem.init(url: currentAudioFileURL)
            player = AVPlayer.init(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            player?.play()
            actionLabel.isHidden = false
            actionLabel.text = NSLocalizedString("ReplayActionText", comment: "")
            Analytics.logContentAction(content: scoredChapters[currentChapterIndex], screenName: screenName, action: .replay)
        }
    }

    @objc func didTapRecordButton() {
        listenButton.isSelected = false
        replayButton.isSelected = false
        recordButton.isSelected = true
        if player?.timeControlStatus == .playing {
            player?.pause()
        }
        let newsAudioPlayer = NewsAudioPlayer.shared
        if newsAudioPlayer.status == .playing {
            newsAudioPlayer.status = .paused
        }
        actionLabel.isHidden = false
        actionLabel.text = NSLocalizedString("RecordActionText", comment: "")
        let scoredChapter = scoredChapters[currentChapterIndex]
        startRecording(scoredChapter: scoredChapter)
        buttonsStackView.isHidden = true
        audioVisualizerView.isHidden = false
        if let userId = AWSMobileClient.default().userSub {
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

    @objc
    func playerDidFinishPlaying() {
        listenButton.isSelected = false
        replayButton.isSelected = false
        actionLabel.isHidden = false
        actionLabel.text = NSLocalizedString("RecordPromptActionText", comment: "")
    }

    func startRecording(scoredChapter: ScoredChapter) {
        let audioFileURL = currentAudioFileURL
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            ] as [String : Any]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder!.isMeteringEnabled = true
            audioRecorder!.record()
            audioVisualizerView.prepareBanners()
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { (timer) in
                self.audioRecorder!.updateMeters()
                var audioDB = self.audioRecorder!.averagePower(forChannel: 0)
                if audioDB > self.audioDBLowerLimit {
                    audioDB = (audioDB - self.audioDBLowerLimit) / -self.audioDBLowerLimit
                    self.audioVisualizerView.drawBanner(value: audioDB)
                } else {
                    self.audioVisualizerView.drawBanner(value: 0)
                }
            })
            timer?.fire()
        } catch {
            // TODO: Catch recorder error.
        }
    }
}
