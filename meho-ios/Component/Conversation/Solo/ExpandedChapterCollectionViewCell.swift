//
//  ExpandedChapterCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 3/22/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import TAISDK

enum AudioPlaySpeed : Float {
    case normal = 1.0
    case slow = 0.75
    case slowest = 0.5

    func displayString() -> String {
        return String(self.rawValue) + "x"
    }

    func next() -> AudioPlaySpeed {
        switch self {
        case .normal:
            return .slow
        case .slow:
            return .slowest
        case .slowest:
            return .normal
        }
    }
}

class ExpandedChapterCollectionViewCell: UICollectionViewCell, AVAudioRecorderDelegate, AudioVisualizerViewDelegte {

    // MARK: - Constants
    private let contentLabelFontSize = CGFloat(24)
    private let contentPinyinLabelFontSize = CGFloat(16)
    private let contentInLocalLanguageLabelFontSize = CGFloat(16)
    private let actionLabelFontSize = CGFloat(14)
    private let contentLeadingTrailingMargin = CGFloat(50)
    private let contentsMargin = CGFloat(12)
    private let avatarViewTopBottomMargin = CGFloat(15)
    private let avatarViewSize = CGFloat(70)
    private let scoreViewTralingMargin = CGFloat(16)
    private let actionLabelTopMargin = CGFloat(28)
    private let actionButtonsTopMargin = CGFloat(12)
    private let actionButtonsBottomMargin = CGFloat(25)
    private let actionButtonsMargin = CGFloat(48)
    private let speedButtonBottomMargin = CGFloat(2)
    private static let recordButtonSize = CGFloat(70)
    private static let listenButtonSize = CGFloat(50)
    private static let replayButtonSize = CGFloat(50)
    private let speedButtonFontSize = CGFloat(16)
    private let backgroundColorAlpha = CGFloat(0.1)
    private let saveButtonWidth = CGFloat(30)
    private let saveButtonHeight = CGFloat(30)
    private let saveButtonTopMargin = CGFloat(16)
    private let saveButtonLeadingMargin = CGFloat(16)
    private static let recordButtonNormalImageName = "conversation_microphone_inactive"
    private static let listenButtonNormalImageName = "conversation_headset_inactive"
    private static let replayButtonNormalImageName = "conversation_play_inactive"
    private static let recordButtonSelectedImageName = "conversation_microphone_active"
    private static let listenButtonSelectedImageName = "conversation_headset_active"
    private static let replayButtonSelectedImageName = "conversation_play_active"
    private static let replayButtonDisabledImageName = "conversation_play_disabled"
    private let audioDBLowerLimit = Float(-30)

    // MARK: - Properties
    // MARK: UI
    private lazy var avatarView: UIImageView = {
        let avatarView = UIImageView.init(frame: .zero)
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = avatarViewSize / 2
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        return avatarView
    } ()

    private lazy var scoreView: ChapterScoreView = {
        let chapterScoreView = ChapterScoreView.init(frame: .zero)
        chapterScoreView.translatesAutoresizingMaskIntoConstraints = false
        return chapterScoreView
    } ()

    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel.init(frame: .zero)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .darkGray
        contentLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: contentLabelFontSize)
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        return contentLabel
    } ()

    private lazy var contentPinyinLabel: UILabel = {
        let contentInLocalLanguageLabel = UILabel.init(frame: .zero)
        contentInLocalLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentInLocalLanguageLabel.textColor = .darkGray
        let contentInLocalLanguageFontDescriptor = UIFont.systemFont(ofSize: contentInLocalLanguageLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        contentInLocalLanguageLabel.font = UIFont.init(descriptor: contentInLocalLanguageFontDescriptor!, size: contentInLocalLanguageLabelFontSize)
        contentInLocalLanguageLabel.numberOfLines = 0
        contentInLocalLanguageLabel.textAlignment = .center
        return contentInLocalLanguageLabel
    } ()

    private lazy var contentInLocalLanguageLabel: UILabel = {
        let contentPinyinLabel = UILabel.init(frame: .zero)
        contentPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPinyinLabel.textColor = .darkGray
        let contentPinyinFontDescriptor = UIFont.systemFont(ofSize: contentPinyinLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        contentPinyinLabel.font = UIFont.init(descriptor: contentPinyinFontDescriptor!, size: contentPinyinLabelFontSize)
        contentPinyinLabel.numberOfLines = 0
        contentPinyinLabel.textAlignment = .center
        return contentPinyinLabel
    } ()

    private lazy var actionLabel: UILabel = {
        let actionLabel = UILabel.init(frame: .zero)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.textColor = .textBlueGray
        let actionLabelFontDescriptor = UIFont.systemFont(ofSize: actionLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        actionLabel.font = UIFont.init(descriptor: actionLabelFontDescriptor!, size: actionLabelFontSize)
        actionLabel.numberOfLines = 1
        actionLabel.text = NSLocalizedString("ListenActionText", comment: "")
        actionLabel.isHidden = true
        actionLabel.textAlignment = .center
        return actionLabel
    } ()

    private lazy var audioVisualizerView: AudioVisualizerView = {
        let audioVisualizerView = AudioVisualizerView.init(frame: .zero)
        audioVisualizerView.isHidden = true
        audioVisualizerView.translatesAutoresizingMaskIntoConstraints = false
        audioVisualizerView.delegate = self
        return audioVisualizerView
    } ()

    private lazy var actionButtonsContainerView: UIView = {
        let actionButtonsContainerView = UIView.init(frame: .zero)
        actionButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        actionButtonsContainerView.addSubview(recordButton)
        actionButtonsContainerView.addSubview(listenButton)
        actionButtonsContainerView.addSubview(replayButton)
        actionButtonsContainerView.addSubview(speedButton)
        return actionButtonsContainerView
    } ()

    private lazy var recordButton: UIButton = {
        let recordButton = UIButton.init(frame: .zero)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        let recordButtonNormalImage = UIImage.init(named: ExpandedChapterCollectionViewCell.recordButtonNormalImageName)
        recordButton.setImage(recordButtonNormalImage, for: .normal)
        let recordButtonSelectedImage = UIImage.init(named: ExpandedChapterCollectionViewCell.recordButtonSelectedImageName)
        recordButton.setImage(recordButtonSelectedImage, for: .selected)
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = ExpandedChapterCollectionViewCell.recordButtonSize / 2
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        return recordButton
    } ()

    private lazy var listenButton: UIButton = {
        let listenButton = UIButton.init(frame: .zero)
        listenButton.translatesAutoresizingMaskIntoConstraints = false
        let listenButtonNormalImage = UIImage.init(named: ExpandedChapterCollectionViewCell.listenButtonNormalImageName)
        listenButton.setImage(listenButtonNormalImage, for: .normal)
        let listenButtonEnabledImage = UIImage.init(named: ExpandedChapterCollectionViewCell.listenButtonSelectedImageName)
        listenButton.setImage(listenButtonEnabledImage, for: .selected)
        listenButton.clipsToBounds = true
        listenButton.layer.cornerRadius = ExpandedChapterCollectionViewCell.listenButtonSize / 2
        listenButton.addTarget(self, action: #selector(didTapListenButton), for: .touchUpInside)
        return listenButton
    } ()

    private lazy var replayButton: UIButton = {
        let replayButton = UIButton.init(frame: .zero)
        replayButton.translatesAutoresizingMaskIntoConstraints = false
        let replayButtonNormalImage = UIImage.init(named: ExpandedChapterCollectionViewCell.replayButtonNormalImageName)
        replayButton.setImage(replayButtonNormalImage, for: .normal)
        let replayButtonEnabledImage = UIImage.init(named: ExpandedChapterCollectionViewCell.replayButtonSelectedImageName)
        replayButton.setImage(replayButtonEnabledImage, for: .selected)
        let replayButtonDisabledImage = UIImage.init(named: ExpandedChapterCollectionViewCell.replayButtonDisabledImageName)
        replayButton.setImage(replayButtonDisabledImage, for: .disabled)
        replayButton.clipsToBounds = true
        replayButton.layer.cornerRadius = ExpandedChapterCollectionViewCell.replayButtonSize / 2
        replayButton.addTarget(self, action: #selector(didTapReplayButton), for: .touchUpInside)
        return replayButton
    } ()

    private lazy var speedButton: UIButton = {
        let speedButton = UIButton.init(frame: .zero)
        speedButton.translatesAutoresizingMaskIntoConstraints = false
        speedButton.setTitleColor(.skyBlue, for: .normal)
        speedButton.setTitle(AudioPlaySpeed.normal.displayString(), for: .normal)
        let speedButtonFontDescriptor = UIFont.systemFont(ofSize: speedButtonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        speedButton.titleLabel?.font = UIFont.init(descriptor: speedButtonFontDescriptor!, size: speedButtonFontSize)
        speedButton.addTarget(self, action: #selector(didTapSpeedButton), for: .touchUpInside)
        return speedButton
    } ()

    private lazy var avatarViewHeightConstraint: NSLayoutConstraint = {
        let avatarViewHeightConstraint = avatarView.heightAnchor.constraint(equalToConstant: avatarViewSize)
        avatarViewHeightConstraint.isActive = true
        return avatarViewHeightConstraint
    } ()

    private lazy var avatarViewTopMarginConstraint: NSLayoutConstraint = {
        let avatarViewTopMarginConstraint = avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: avatarViewTopBottomMargin)
        avatarViewTopMarginConstraint.isActive = true
        return avatarViewTopMarginConstraint
    } ()

    private lazy var saveButton: UIButton = {
        let saveButton = UIButton.init(frame: .zero)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        let saveButtonImage = UIImage.init(named: "purple_saved_unfilled")
        saveButton.setImage(saveButtonImage, for: .normal)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        saveButton.isHidden = true
        return saveButton
    } ()

    // MARK: Model
    private var scoredChapter: ScoredChapter!
    private var audioRecorder: AVAudioRecorder?
    private static var sizingCell = ExpandedChapterCollectionViewCell.init(frame: .zero);
    private let oralEvaluation = TAIOralEvaluation.init()
    private var audioFileURL: URL?
    private var player: AVPlayer?
    private var currentAudioPlaySpeed = AudioPlaySpeed.normal
    private var timer: Timer?
    private let contentEvaluator = ContentEvaluator.init()

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.skyBlue.withAlphaComponent(backgroundColorAlpha)

        contentView.addSubview(avatarView)
        contentView.addSubview(scoreView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(contentPinyinLabel)
        contentView.addSubview(contentInLocalLanguageLabel)
        contentView.addSubview(actionLabel)
        contentView.addSubview(actionButtonsContainerView)
        contentView.addSubview(audioVisualizerView)
        contentView.addSubview(saveButton)

        // Sets up layout constraints
        avatarView.widthAnchor.constraint(equalToConstant: avatarViewSize).isActive = true
        avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

        scoreView.centerYAnchor.constraint(equalTo: contentLabel.centerYAnchor).isActive = true
        scoreView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -scoreViewTralingMargin).isActive = true

        contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        contentLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: avatarViewTopBottomMargin).isActive = true

        contentPinyinLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        contentPinyinLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
        contentPinyinLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: contentsMargin).isActive = true

        contentInLocalLanguageLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        contentInLocalLanguageLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
        contentInLocalLanguageLabel.topAnchor.constraint(equalTo: contentPinyinLabel.bottomAnchor, constant: contentsMargin).isActive = true

        actionLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        actionLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
        actionLabel.topAnchor.constraint(equalTo: contentInLocalLanguageLabel.bottomAnchor, constant: actionLabelTopMargin).isActive = true

        actionButtonsContainerView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        actionButtonsContainerView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
        actionButtonsContainerView.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: actionButtonsTopMargin).isActive = true
        actionButtonsContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        actionButtonsContainerView.heightAnchor.constraint(equalToConstant: ExpandedChapterCollectionViewCell.recordButtonSize + actionButtonsBottomMargin).isActive = true

        audioVisualizerView.topAnchor.constraint(equalTo: actionButtonsContainerView.topAnchor).isActive = true
        audioVisualizerView.bottomAnchor.constraint(equalTo: actionButtonsContainerView.bottomAnchor).isActive = true
        audioVisualizerView.leadingAnchor.constraint(equalTo: actionButtonsContainerView.leadingAnchor).isActive = true
        audioVisualizerView.trailingAnchor.constraint(equalTo: actionButtonsContainerView.trailingAnchor).isActive = true

        recordButton.centerXAnchor.constraint(equalTo: actionButtonsContainerView.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: ExpandedChapterCollectionViewCell.recordButtonSize).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: ExpandedChapterCollectionViewCell.recordButtonSize).isActive = true
        recordButton.topAnchor.constraint(equalTo: actionButtonsContainerView.topAnchor).isActive = true

        listenButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        listenButton.widthAnchor.constraint(equalToConstant: ExpandedChapterCollectionViewCell.listenButtonSize).isActive = true
        listenButton.heightAnchor.constraint(equalToConstant: ExpandedChapterCollectionViewCell.listenButtonSize).isActive = true
        listenButton.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -actionButtonsMargin).isActive = true

        replayButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        replayButton.widthAnchor.constraint(equalToConstant: ExpandedChapterCollectionViewCell.replayButtonSize).isActive = true
        replayButton.heightAnchor.constraint(equalToConstant: ExpandedChapterCollectionViewCell.replayButtonSize).isActive = true
        replayButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: actionButtonsMargin).isActive = true

        speedButton.bottomAnchor.constraint(equalTo: actionButtonsContainerView.bottomAnchor, constant: -speedButtonBottomMargin).isActive = true
        speedButton.centerXAnchor.constraint(equalTo: listenButton.centerXAnchor).isActive = true

        saveButton.widthAnchor.constraint(equalToConstant: saveButtonWidth).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: saveButtonHeight).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: saveButtonLeadingMargin).isActive = true
        saveButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: saveButtonTopMargin).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - UICollectionViewCell
    override func prepareForReuse() {
        super.prepareForReuse()
        if player?.timeControlStatus == .playing {
            player?.pause()
            player = nil
        }
        contentLabel.text = nil
        contentLabel.attributedText = nil
        contentPinyinLabel.text = nil
        contentInLocalLanguageLabel.text = nil
        actionButtonsContainerView.isHidden = false
        audioVisualizerView.isHidden = true
        listenButton.isSelected = false
        replayButton.isSelected = false
        recordButton.isSelected = false
        actionLabel.isHidden = true
        currentAudioPlaySpeed = .normal
        speedButton.setTitle(currentAudioPlaySpeed.displayString(), for: .normal)
    }

    // MARK: - Internal
    func setScoredChapter(_ scoredChapter: ScoredChapter, isSaveButtonHidden: Bool) {
        let chapter = scoredChapter.chapter
        if let scoredContent = scoredChapter.scoredContent {
            contentLabel.attributedText = scoredContent
        } else {
            contentLabel.textColor = .darkGray
            contentLabel.text = chapter.content
        }
        contentPinyinLabel.text = chapter.contentPinyin
        contentInLocalLanguageLabel.text = chapter.contentInLocalLanguage
        if scoredChapter.shouldDisplayScore {
            scoreView.setScore(scoredChapter.score)
        } else {
            scoreView.isHidden = true
        }
        if chapter.role.count > 0 {
            avatarView.image = RoleUtils.avatarImage(with: chapter.role)
            avatarViewHeightConstraint.constant = avatarViewSize
            avatarViewTopMarginConstraint.constant = avatarViewTopBottomMargin
        } else {
            avatarView.image = nil
            avatarViewHeightConstraint.constant = 0
            avatarViewTopMarginConstraint.constant = 0
        }
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
        isDirectory: true)
        let identifier = chapter.identifier
        let audioFileName = "\(identifier).caf"
        audioFileURL = temporaryDirectoryURL.appendingPathComponent(audioFileName)
        replayButton.isEnabled = FileManager.default.fileExists(atPath: audioFileURL!.path)
        self.scoredChapter = scoredChapter
        saveButton.isHidden = isSaveButtonHidden
    }

    func playAudio() {
        didTapListenButton()
    }

    func stopAudio() {
        player?.pause()
        player = nil
    }

    class func cellHeight(with width: CGFloat, chapter: Chapter) -> CGFloat {
        sizingCell.contentLabel.text = chapter.content
        sizingCell.contentPinyinLabel.text = chapter.contentPinyin
        sizingCell.contentInLocalLanguageLabel.text = chapter.contentInLocalLanguage
        var height = sizingCell.avatarViewTopBottomMargin + 2 * sizingCell.contentsMargin + sizingCell.actionLabelTopMargin + sizingCell.actionButtonsTopMargin + sizingCell.actionButtonsBottomMargin + recordButtonSize
        if chapter.role.count > 0 {
            height += sizingCell.avatarViewSize + sizingCell.avatarViewTopBottomMargin
        }
        let contentWidth = width - 2 * sizingCell.contentLeadingTrailingMargin
        height += sizingCell.contentLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        height += sizingCell.contentPinyinLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        height += sizingCell.contentInLocalLanguageLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        height += sizingCell.actionLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        return height
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
            let content = scoredChapter.chapter.content
            contentEvaluator.evaluate(content: content, audioFileURL: audioFileURL!) { (result) in
                switch result {
                case .success(let contentEvaluationResult):
                    let suggestedScore = contentEvaluationResult.score
                    if self.scoredChapter.shouldDisplayScore {
                        self.scoreView.setScore(suggestedScore)
                    }
                    self.scoredChapter.score = suggestedScore
                    let scoredContent = contentEvaluationResult.scoredContent
                    self.contentLabel.attributedText = scoredContent
                    self.scoredChapter.scoredContent = scoredContent
                    self.actionLabel.isHidden = false
                    if self.scoredChapter.shouldDisplayScore {
                        self.actionLabel.text = NSLocalizedString("ReplayPromptActionText", comment: "")
                    } else {
                        self.actionLabel.text = NSLocalizedString("ReplayWithoutScorePromptActionText", comment: "")
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
    }

    // MARK: - Private
    @objc func didTapListenButton() {
        if let audioURL = scoredChapter.chapter.contentAudioURL {
            listenButton.isSelected = true
            replayButton.isSelected = false
            recordButton.isSelected = false
            let playerItem = AVPlayerItem.init(url: audioURL)
            playerItem.audioTimePitchAlgorithm = .spectral
            player = AVPlayer.init(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            player?.play()
            player?.rate = currentAudioPlaySpeed.rawValue
            actionLabel.text = NSLocalizedString("ListenActionText", comment: "")
            actionLabel.isHidden = false
        }
    }

    @objc func didTapReplayButton() {
        if audioFileURL != nil && FileManager.default.fileExists(atPath: audioFileURL!.path) {
            listenButton.isSelected = false
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

    @objc func didTapRecordButton() {
        listenButton.isSelected = false
        replayButton.isSelected = false
        recordButton.isSelected = true
        if player?.timeControlStatus == .playing {
            player?.pause()
        }
        actionLabel.isHidden = false
        actionLabel.text = NSLocalizedString("RecordActionText", comment: "")
        startRecording()
        actionButtonsContainerView.isHidden = true
        audioVisualizerView.isHidden = false
    }

    @objc func didTapSpeedButton() {
        currentAudioPlaySpeed = currentAudioPlaySpeed.next()
        speedButton.setTitle(currentAudioPlaySpeed.displayString(), for: .normal)
        if player != nil {
            player?.rate = currentAudioPlaySpeed.rawValue
        }
    }

    @objc
    func didTapSaveButton() {
        // TODO: Implement
    }

    @objc func playerDidFinishPlaying() {
        listenButton.isSelected = false
        replayButton.isSelected = false
        actionLabel.isHidden = false
        actionLabel.text = NSLocalizedString("RecordPromptActionText", comment: "")
    }

    func startRecording() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            ] as [String : Any]
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
