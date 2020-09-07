//
//  DuoDetailedDialogViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAnalytics

class DuoDetailedDialogViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AudioVisualizerViewDelegte, AVAudioRecorderDelegate, DuoYourRoleCollectionViewCellDelegate, DuoFinalScoreViewControllerDelegate, MehoAnalytics {

    // MARK: - Constants
    private static let replayButtonNormalImageName = "conversation_play_inactive"
    private static let replayButtonSelectedImageName = "conversation_play_active"
    private static let replayButtonDisabledImageName = "conversation_play_disabled"
    private static let recordButtonNormalImageName = "conversation_microphone_inactive"
    private static let recordButtonDisabledImageName = "conversation_microphone_disabled"
    private static let nextButtonNormalImageName = "conversation_next"
    private static let nextButtonDisabledImageName = "conversation_next_disabled"
    private static let finishButtonNormalImageName = "conversation_finish"
    private static let recordButtonSize = CGFloat(70)
    private static let replayButtonSize = CGFloat(50)
    private static let nextButtonSize = CGFloat(50)
    private static let actionLabelAndChaptersCollectionViewMargin = CGFloat(24)
    private static let actionLabelFontSize = CGFloat(14)
    private static let recordButtonBottomMargin = CGFloat(40)
    private static let actionButtonsMargin = CGFloat(48)
    private static let actionButtonsTopMargin = CGFloat(24)
    private static let duoOtherRoleCollectionViewCellReuseIdentifier = "duoOtherRoleCollectionViewCellReuseIdentifier"
    private static let duoYourRoleCollectionViewCellReuseIdentifier = "duoYourRoleCollectionViewCellReuseIdentifier"
    private static let changeRoleBarButtonItemImageName = "conversation_ab_role_rotate"
    private let audioDBLowerLimit = Float(-30)
    private let duoFinalScoreViewLeadingTrailingMargin = CGFloat(24)

    // MARK: - Properties
    // MARK: Model
    private var scoredChapters: [ScoredChapter];
    private var currentScoredChapters: [ScoredChapter] = []
    private var player: AVPlayer?
    private var audioFileURL: URL?
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private let contentEvaluator = ContentEvaluator.init()
    private var hasPlayedAudio = false
    private var isYourRoleFirst = false
    private let conversationDataFetcher = ConversationDataFetcher.init()
    private let dialogID: String?
    private var scoreA: Int?
    private var scoreB: Int?

    // MARK: UI
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView.init(progressViewStyle: .bar)
        progressView.progressTintColor = .skyBlue
        return progressView
    } ()

    private lazy var actionLabel: UILabel = {
        let actionLabel = UILabel.init(frame: .zero)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.textColor = .textBlueGray
        let actionLabelFontDescriptor = UIFont.systemFont(ofSize: DuoDetailedDialogViewController.actionLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        actionLabel.font = UIFont.init(descriptor: actionLabelFontDescriptor!, size: DuoDetailedDialogViewController.actionLabelFontSize)
        actionLabel.numberOfLines = 1
        actionLabel.textAlignment = .center
        return actionLabel
    } ()

    private lazy var replayButton: UIButton = {
        let replayButton = UIButton.init(frame: .zero)
        replayButton.translatesAutoresizingMaskIntoConstraints = false
        let replayButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.replayButtonNormalImageName)
        replayButton.setImage(replayButtonNormalImage, for: .normal)
        let replayButtonDisabledImage = UIImage.init(named: DuoDetailedDialogViewController.replayButtonDisabledImageName)
        replayButton.setImage(replayButtonDisabledImage, for: .disabled)
        let replayButtonSelectedImageName = UIImage.init(named: DuoDetailedDialogViewController.replayButtonSelectedImageName)
        replayButton.setImage(replayButtonSelectedImageName, for: .selected)
        replayButton.clipsToBounds = true
        replayButton.layer.cornerRadius = DuoDetailedDialogViewController.replayButtonSize / 2
        replayButton.addTarget(self, action: #selector(didTapReplayButton), for: .touchUpInside)
        return replayButton
    } ()

    private lazy var recordButton: UIButton = {
        let recordButton = UIButton.init(frame: .zero)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        let recordButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.recordButtonNormalImageName)
        recordButton.setImage(recordButtonNormalImage, for: .normal)
        let recordButtonDisabledImage = UIImage.init(named: DuoDetailedDialogViewController.recordButtonDisabledImageName)
        recordButton.setImage(recordButtonDisabledImage, for: .disabled)
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = DuoDetailedDialogViewController.recordButtonSize / 2
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        return recordButton
    } ()

    private lazy var nextButton: UIButton = {
        let nextButton = UIButton.init(frame: .zero)
        let nextButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.nextButtonNormalImageName)
        nextButton.setImage(nextButtonNormalImage, for: .normal)
        let nextButtonDisabledImage = UIImage.init(named: DuoDetailedDialogViewController.nextButtonDisabledImageName)
        nextButton.setImage(nextButtonDisabledImage, for: .disabled)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = DuoDetailedDialogViewController.nextButtonSize / 2
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return nextButton
    } ()

    private lazy var chaptersCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let chaptersCollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        return chaptersCollectionViewFlowLayout
    } ()

    private lazy var chaptersCollectionView: UICollectionView = {
        let chaptersCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: chaptersCollectionViewFlowLayout)
        chaptersCollectionView.backgroundColor = .white
        chaptersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chaptersCollectionView.register(DuoOtherRoleCollectionViewCell.self, forCellWithReuseIdentifier: DuoDetailedDialogViewController.duoOtherRoleCollectionViewCellReuseIdentifier)
        chaptersCollectionView.register(DuoYourRoleCollectionViewCell.self, forCellWithReuseIdentifier: DuoDetailedDialogViewController.duoYourRoleCollectionViewCellReuseIdentifier)
        chaptersCollectionView.dataSource = self
        chaptersCollectionView.delegate = self
        return chaptersCollectionView
    } ()

    private lazy var actionButtonsContainerView: UIView = {
        let actionButtonsContainerView = UIView.init(frame: .zero)
        actionButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        return actionButtonsContainerView
    } ()

    private lazy var audioVisualizerView: AudioVisualizerView = {
        let audioVisualizerView = AudioVisualizerView.init(frame: .zero)
        audioVisualizerView.isHidden = true
        audioVisualizerView.translatesAutoresizingMaskIntoConstraints = false
        audioVisualizerView.delegate = self
        return audioVisualizerView
    } ()

    // MARK: MehoAnalytics
    let screenName = "p_meho_talks_duo"
    let screenClass = "p_meho_talks_duo"

    // MARK: - Init
    init() {
        fatalError("Use init(scoredChapters: [ScoredChapter])")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(scoredChapters: [ScoredChapter])")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(scoredChapters: [ScoredChapter])")
    }

    init(scoredChapters: [ScoredChapter]) {
        self.scoredChapters = scoredChapters
        self.dialogID = nil
        super.init(nibName: nil, bundle: nil)
        setUpNavigationItem()
        loadFirstChapter()
    }

    init(dialogID: String) {
        self.scoredChapters = []
        self.dialogID = dialogID
        super.init(nibName: nil, bundle: nil)
        setUpNavigationItem()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = .white

        view.addSubview(actionLabel)
        view.addSubview(actionButtonsContainerView)
        view.addSubview(audioVisualizerView)
        actionButtonsContainerView.addSubview(replayButton)
        actionButtonsContainerView.addSubview(recordButton)
        actionButtonsContainerView.addSubview(nextButton)
        view.addSubview(chaptersCollectionView)

        if dialogID != nil {
            conversationDataFetcher.fetchDetailedDialog(dialogID: dialogID!) { (dialog, error) in
                if (dialog != nil && error == nil) {
                    self.scoredChapters = dialog!.chapters.map({ (chapter) -> ScoredChapter in
                        return ScoredChapter.init(chapter: chapter)
                    })
                    DispatchQueue.main.async {
                        self.chaptersCollectionView.reloadData()
                        self.loadFirstChapter()
                        let audioSession = AVAudioSession.sharedInstance()
                        audioSession.requestRecordPermission { (allowed) in
                            // TODO: Add UI if not allowed.
                        }
                    }
                }
            }
        } else {
            let audioSession = AVAudioSession.sharedInstance()
            audioSession.requestRecordPermission { (allowed) in
                // TODO: Add UI if not allowed.
            }
        }

        actionButtonsContainerView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -DuoDetailedDialogViewController.recordButtonBottomMargin).isActive = true
        actionButtonsContainerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        actionButtonsContainerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        actionButtonsContainerView.heightAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.recordButtonSize).isActive = true

        audioVisualizerView.topAnchor.constraint(equalTo: actionButtonsContainerView.topAnchor).isActive = true
        audioVisualizerView.bottomAnchor.constraint(equalTo: actionButtonsContainerView.bottomAnchor).isActive = true
        audioVisualizerView.leadingAnchor.constraint(equalTo: actionButtonsContainerView.leadingAnchor).isActive = true
        audioVisualizerView.trailingAnchor.constraint(equalTo: actionButtonsContainerView.trailingAnchor).isActive = true

        recordButton.widthAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.recordButtonSize).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.recordButtonSize).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: actionButtonsContainerView.bottomAnchor).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: actionButtonsContainerView.centerXAnchor).isActive = true

        replayButton.widthAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.replayButtonSize).isActive = true
        replayButton.heightAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.replayButtonSize).isActive = true
        replayButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        replayButton.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -DuoDetailedDialogViewController.actionButtonsMargin).isActive = true

        nextButton.widthAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.nextButtonSize).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: DuoDetailedDialogViewController.nextButtonSize).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: DuoDetailedDialogViewController.actionButtonsMargin).isActive = true

        actionLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        actionLabel.bottomAnchor.constraint(equalTo: actionButtonsContainerView.topAnchor, constant: -DuoDetailedDialogViewController.actionButtonsTopMargin).isActive = true

        chaptersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chaptersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chaptersCollectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        chaptersCollectionView.bottomAnchor.constraint(equalTo: actionLabel.topAnchor, constant: -DuoDetailedDialogViewController.actionLabelAndChaptersCollectionViewMargin).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentScoredChapters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        let isActive = item == currentScoredChapters.count - 1
        let name = item % 2 == 0 ? NSLocalizedString("RoleAText", comment: "") : NSLocalizedString("RoleBText", comment: "")
        if isChapterYourRole(index: item) {
            if let duoYourRoleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: DuoDetailedDialogViewController.duoYourRoleCollectionViewCellReuseIdentifier, for: indexPath) as? DuoYourRoleCollectionViewCell {
                duoYourRoleCollectionViewCell.delegate = self
                duoYourRoleCollectionViewCell.setScoredChapter(currentScoredChapters[item], isActive: isActive, name: name)
                return duoYourRoleCollectionViewCell
            }
        } else {
            if let duoOtherRoleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: DuoDetailedDialogViewController.duoOtherRoleCollectionViewCellReuseIdentifier, for: indexPath) as? DuoOtherRoleCollectionViewCell {
                duoOtherRoleCollectionViewCell.setScoredChapter(currentScoredChapters[item], isActive: isActive, name: name)
                return duoOtherRoleCollectionViewCell
            }
        }

        return UICollectionViewCell.init()
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = indexPath.item
        let width = collectionView.bounds.width
        if isChapterYourRole(index: item) {
            let height = DuoYourRoleCollectionViewCell.cellHeight(with: width, scoredChapter: currentScoredChapters[indexPath.item])
            return CGSize.init(width: width, height: height)
        } else {
            let height = DuoOtherRoleCollectionViewCell.cellHeight(with: width, scoredChapter: currentScoredChapters[indexPath.item])
            return CGSize.init(width: width, height: height)
        }
    }

    // MARK: - AudioVisualizerViewDelegte
    func audioVisualizerViewDidTapInside(_ audioVisualizerView: AudioVisualizerView) {
        actionButtonsContainerView.isHidden = false
        audioVisualizerView.isHidden = true
        timer?.invalidate()
        timer = nil
        recordButton.isSelected = false
        actionLabel.isHidden = true
        audioRecorder?.stop()
        if audioFileURL != nil {
            replayButton.isEnabled = FileManager.default.fileExists(atPath: audioFileURL!.path)
            if let content = currentScoredChapters.last?.chapter.content {
                contentEvaluator.evaluate(content: content, audioFileURL: audioFileURL!) { (result) in
                    switch result {
                    case .success(let contentEvaluationResult):
                        if let scoredChapter = self.currentScoredChapters.last {
                            let suggestedScore = contentEvaluationResult.score
                            scoredChapter.score = suggestedScore
                            let scoredContent = contentEvaluationResult.scoredContent
                            scoredChapter.scoredContent = scoredContent
                            self.actionLabel.isHidden = false
                            self.actionLabel.text = NSLocalizedString("ReplayPromptActionText", comment: "")
                            let currentIndexPath = IndexPath.init(item: self.currentScoredChapters.count - 1, section: 0)
                            self.chaptersCollectionView.reloadItems(at: [currentIndexPath])
                            self.refreshButtonStates()
                        }
                        break
                    case .failure(let error):
                        self.actionLabel.isHidden = false
                        self.actionLabel.text = NSLocalizedString("RecordPromptActionText", comment: "")
                        print(error.localizedDescription)
                        break
                    }
                }
            }
        }
    }

    // MARK: - DuoYourRoleCollectionViewCellDelegate
    func duoYourRoleCollectionViewCellDidTapSpeakerButton(_ view: DuoYourRoleCollectionViewCell) {
        playCurrentChapter()
    }

    // MARK: - DuoFinalScoreViewControllerDelegate
    func duoFinalScoreViewControllerDidFinish() {
        dismiss(animated: true, completion: nil)
    }

    func duoFinalScoreViewControllerDidContinueWithRole(role: String) {
        dismiss(animated: true, completion: nil)
        didTapchangeRoleBarButtonItem()
    }

    // MARK: - Private
    @objc func didTapReplayButton() {
        if audioFileURL != nil && FileManager.default.fileExists(atPath: audioFileURL!.path) {
            replayButton.isSelected = true
            recordButton.isSelected = false
            let playerItem = AVPlayerItem.init(url: audioFileURL!)
            player = AVPlayer.init(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            player?.play()
            actionLabel.isHidden = false
            actionLabel.text = NSLocalizedString("ReplayActionText", comment: "")
        }
    }

    @objc
    func didTapRecordButton() {
        recordButton.isSelected = true
        actionLabel.isHidden = false
        actionLabel.text = NSLocalizedString("RecordActionText", comment: "")
        startRecording()
        actionButtonsContainerView.isHidden = true
        audioVisualizerView.isHidden = false
    }

    @objc
    func didTapNextButton() {
        if (currentScoredChapters.count == scoredChapters.count) {
            var score = 0
            var numberOfScores = 0
            if isYourRoleFirst {
                for (index, scoredChapter) in currentScoredChapters.enumerated() {
                    if index % 2 == 0 {
                        numberOfScores = numberOfScores + 1
                        score = score + Int(scoredChapter.score)
                    }
                }
                self.scoreA = score / numberOfScores
            } else {
                for (index, scoredChapter) in currentScoredChapters.enumerated() {
                    if index % 2 == 1 {
                        numberOfScores = numberOfScores + 1
                        score = score + Int(scoredChapter.score)
                    }
                }
                self.scoreB = score / numberOfScores
            }

            let duoFinalScoreViewController = DuoFinalScoreViewController.init(scoreA: scoreA, scoreB: scoreB)
            duoFinalScoreViewController.delegate = self
            let viewWidth = view.bounds.width - duoFinalScoreViewLeadingTrailingMargin * 2
            let viewHeight = duoFinalScoreViewController.viewHeight(width: viewWidth)
            duoFinalScoreViewController.preferredContentSize = CGSize.init(width: viewWidth, height: viewHeight)
            let dialogViewController = DialogViewController.init(contentViewController: duoFinalScoreViewController)
            dialogViewController.modalPresentationStyle = .overFullScreen
            dialogViewController.modalTransitionStyle = .crossDissolve
            present(dialogViewController, animated: true, completion: nil)
            return
        }
        let newScoredChapterIndex = currentScoredChapters.count
        currentScoredChapters.append(scoredChapters[newScoredChapterIndex])
        let newIndexPath = IndexPath.init(item: newScoredChapterIndex, section: 0)
        chaptersCollectionView.insertItems(at: [newIndexPath])
        let lastIndexPath = IndexPath.init(item: newScoredChapterIndex - 1, section: 0)
        chaptersCollectionView.reloadItems(at: [lastIndexPath])
        chaptersCollectionView.scrollToItem(at: newIndexPath, at: .bottom, animated: true)
        let progress = Float(currentScoredChapters.count) / Float(scoredChapters.count)
        progressView.setProgress(progress, animated: true)
        clearStates()
        refreshButtonStates()
        playCurrentChapter()
        if isCurrentChapterYourRole() {
            actionLabel.text = NSLocalizedString("ListenActionText", comment: "")
        } else {
            let currentRoleFormat = NSLocalizedString("CurrentRoleText", comment: "")
            let currentRole = isYourRoleFirst ? NSLocalizedString("RoleAText", comment: "") : NSLocalizedString("RoleBText", comment: "")
            actionLabel.text = String.init(format: currentRoleFormat, currentRole)
        }
    }

    @objc
    func didTapchangeRoleBarButtonItem() {
        clearStates()
        isYourRoleFirst = !isYourRoleFirst
        currentScoredChapters = Array(currentScoredChapters[0...0])
        chaptersCollectionView.reloadData()
        let nextButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.nextButtonNormalImageName)
        nextButton.setImage(nextButtonNormalImage, for: .normal)
        let nextButtonDisabledImage = UIImage.init(named: DuoDetailedDialogViewController.nextButtonDisabledImageName)
        nextButton.setImage(nextButtonDisabledImage, for: .disabled)
        refreshButtonStates()
        let currentRoleFormat = NSLocalizedString("CurrentRoleText", comment: "")
        let currentRole = isYourRoleFirst ? NSLocalizedString("RoleAText", comment: "") : NSLocalizedString("RoleBText", comment: "")
        actionLabel.text = String.init(format: currentRoleFormat, currentRole)
        playCurrentChapter()
    }

    func playCurrentChapter() {
        if let currentChapter = currentScoredChapters.last, let contentAudioURL = currentChapter.chapter.contentAudioURL {
            let playerItem = AVPlayerItem.init(url: contentAudioURL)
            playerItem.audioTimePitchAlgorithm = .spectral
            player = AVPlayer.init(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            player?.play()
        }
    }

    @objc func playerDidFinishPlaying() {
        hasPlayedAudio = true
        if isCurrentChapterYourRole() {
            actionLabel.text = ""
            refreshButtonStates()
        } else {
            didTapNextButton()
        }
    }

    private func startRecording() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            ] as [String : Any]
        if let identifier = currentScoredChapters.last?.chapter.identifier {
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),isDirectory: true)
            let audioFileName = "\(identifier).caf"
            audioFileURL = temporaryDirectoryURL.appendingPathComponent(audioFileName)
            if audioFileURL != nil {
                do {
                    audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
                    audioRecorder!.delegate = self
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
    }

    private func isCurrentChapterYourRole() -> Bool {
        let currentIndex = currentScoredChapters.count - 1
        return isChapterYourRole(index: currentIndex)
    }

    private func isChapterYourRole(index: Int) -> Bool {
        if isYourRoleFirst {
            return index % 2 == 0
        } else {
            return index % 2 == 1
        }
    }

    private func clearStates() {
        hasPlayedAudio = false
        audioFileURL = nil
        player = nil
    }

    private func refreshButtonStates() {
        if (isCurrentChapterYourRole()) {
            replayButton.isEnabled = audioFileURL != nil
            if replayButton.isSelected {
                replayButton.isSelected = false
            }
            recordButton.isEnabled = hasPlayedAudio
            if currentScoredChapters.last?.scoredContent != nil {
                if currentScoredChapters.count == scoredChapters.count {
                    let finishButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.finishButtonNormalImageName)
                    nextButton.setImage(finishButtonNormalImage, for: .normal)
                    let finishButtonDisabledImage = UIImage.init(named: DuoDetailedDialogViewController.finishButtonNormalImageName)
                    nextButton.setImage(finishButtonDisabledImage, for: .disabled)
                }
                nextButton.isEnabled = true
            } else {
                nextButton.isEnabled = false
            }
        } else {
            replayButton.isEnabled = false
            recordButton.isEnabled = false
            nextButton.isEnabled = true
            if currentScoredChapters.count == scoredChapters.count {
                let finishButtonNormalImage = UIImage.init(named: DuoDetailedDialogViewController.finishButtonNormalImageName)
                nextButton.setImage(finishButtonNormalImage, for: .normal)
                let finishButtonDisabledImage = UIImage.init(named: DuoDetailedDialogViewController.finishButtonNormalImageName)
                nextButton.setImage(finishButtonDisabledImage, for: .disabled)
            }
        }
    }

    private func loadFirstChapter() {
        if let firstChapter = scoredChapters.first {
            currentScoredChapters.append(firstChapter)
            let progress = Float(currentScoredChapters.count) / Float(scoredChapters.count)
            progressView.setProgress(progress, animated: false)
            refreshButtonStates()
            let currentRoleFormat = NSLocalizedString("CurrentRoleText", comment: "")
            let currentRole = isYourRoleFirst ? NSLocalizedString("RoleAText", comment: "") : NSLocalizedString("RoleBText", comment: "")
            actionLabel.text = String.init(format: currentRoleFormat, currentRole)
            playCurrentChapter()
        }
    }

    private func setUpNavigationItem() {
        navigationItem.titleView = progressView
        let changeRoleBarButtonItemImage = UIImage.init(named: DuoDetailedDialogViewController.changeRoleBarButtonItemImageName)
        let changeRoleBarButtonItem = UIBarButtonItem.init(image: changeRoleBarButtonItemImage, style: .plain, target: self, action: #selector(didTapchangeRoleBarButtonItem))
        navigationItem.rightBarButtonItem = changeRoleBarButtonItem
    }
}
