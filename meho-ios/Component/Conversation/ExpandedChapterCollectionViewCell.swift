//
//  ExpandedChapterCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 3/22/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation

class ExpandedChapterCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let contentLabelFontSize = CGFloat(24)
    private let contentPinyinLabelFontSize = CGFloat(16)
    private let contentInLocalLanguageLabelFontSize = CGFloat(16)
    private let actionLabelFontSize = CGFloat(14)
    private let contentLeadingTrailingMargin = CGFloat(50)
    private let contentsMargin = CGFloat(12)
    private let avatarViewTopBottomMargin = CGFloat(15)
    private let avatarViewSize = CGFloat(70)
    private let actionLabelTopMargin = CGFloat(28)
    private let actionButtonTopBottomMargin = CGFloat(12)
    private let actionButtonsMargin = CGFloat(48)
    private let recordButtonSize = CGFloat(70)
    private let listenButtonSize = CGFloat(50)
    private let replayButtonSize = CGFloat(50)
    private let backgroundColorAlpha = CGFloat(0.05)
    private let recordButtonNormalImageName = "conversation_microphone_inactive"
    private let listenButtonNormalImageName = "conversation_headset_inactive"
    private let replayButtonNormalImageName = "conversation_play_inactive"
    private let recordButtonSelectedImageName = "conversation_microphone_active"
    private let listenButtonSelectedImageName = "conversation_headset_active"
    private let avatar1ImageName = "conversation_facepile1"

    // MARK: - Properties
    private let avatarView = UIImageView.init(frame: .zero)
    private let contentLabel = UILabel.init(frame: .zero)
    private let contentPinyinLabel = UILabel.init(frame: .zero)
    private let contentInLocalLanguageLabel = UILabel.init(frame: .zero)
    private let actionLabel = UILabel.init(frame: .zero)
    private let recordButton = UIButton.init(frame: .zero)
    private let listenButton = UIButton.init(frame: .zero)
    private let replayButton = UIButton.init(frame: .zero)
    private var player: AVPlayer?
    private var audioURL: URL?
    private static var sizingCell = ExpandedChapterCollectionViewCell.init(frame: .zero);

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.skyBlue.withAlphaComponent(backgroundColorAlpha)

        // Sets up the avatar view.
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = avatarViewSize / 2
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        let avatarImage = UIImage.init(named: avatar1ImageName)
        avatarView.image = avatarImage
        contentView.addSubview(avatarView)

        // Sets up the content label.
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .darkGray
        contentLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: contentLabelFontSize)
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        contentView.addSubview(contentLabel)

        // Sets up the content pinyin label.
        contentPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPinyinLabel.textColor = .darkGray
        let contentPinyinFontDescriptor = UIFont.systemFont(ofSize: contentPinyinLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        contentPinyinLabel.font = UIFont.init(descriptor: contentPinyinFontDescriptor!, size: contentPinyinLabelFontSize)
        contentPinyinLabel.numberOfLines = 0
        contentPinyinLabel.textAlignment = .center
        contentView.addSubview(contentPinyinLabel)

        // Sets up the content in local language label.
        contentInLocalLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentInLocalLanguageLabel.textColor = .darkGray
        let contentInLocalLanguageFontDescriptor = UIFont.systemFont(ofSize: contentInLocalLanguageLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        contentInLocalLanguageLabel.font = UIFont.init(descriptor: contentInLocalLanguageFontDescriptor!, size: contentInLocalLanguageLabelFontSize)
        contentInLocalLanguageLabel.numberOfLines = 0
        contentInLocalLanguageLabel.textAlignment = .center
        contentView.addSubview(contentInLocalLanguageLabel)

        // Sets up the action label.
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.textColor = .textBlueGray
        let actionLabelFontDescriptor = UIFont.systemFont(ofSize: actionLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        actionLabel.font = UIFont.init(descriptor: actionLabelFontDescriptor!, size: actionLabelFontSize)
        actionLabel.numberOfLines = 1
        contentView.addSubview(actionLabel)

        // Sets up the record button.
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        let recordButtonNormalImage = UIImage.init(named: recordButtonNormalImageName)
        recordButton.setImage(recordButtonNormalImage, for: .normal)
        let recordButtonSelectedImage = UIImage.init(named: recordButtonSelectedImageName)
        recordButton.setImage(recordButtonSelectedImage, for: .selected)
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = recordButtonSize / 2
        recordButton.addTarget(self, action: #selector(didTapRecordButton), for: .touchUpInside)
        contentView.addSubview(recordButton)

        // Sets up the listen button.
        listenButton.translatesAutoresizingMaskIntoConstraints = false
        let listenButtonNormalImage = UIImage.init(named: listenButtonNormalImageName)
        listenButton.setImage(listenButtonNormalImage, for: .normal)
        let listenButtonEnabledImage = UIImage.init(named: listenButtonSelectedImageName)
        listenButton.setImage(listenButtonEnabledImage, for: .selected)
        listenButton.clipsToBounds = true
        listenButton.layer.cornerRadius = listenButtonSize / 2
        listenButton.addTarget(self, action: #selector(didTapListenButton), for: .touchUpInside)
        contentView.addSubview(listenButton)

        // Sets up the replay button.
        replayButton.translatesAutoresizingMaskIntoConstraints = false
        let replayButtonNormalImage = UIImage.init(named: replayButtonNormalImageName)
        replayButton.setImage(replayButtonNormalImage, for: .normal)
        replayButton.clipsToBounds = true
        replayButton.layer.cornerRadius = replayButtonSize / 2
        contentView.addSubview(replayButton)

        // Sets up layout constraints
        avatarView.widthAnchor.constraint(equalToConstant: avatarViewSize).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: avatarViewSize).isActive = true
        avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: avatarViewTopBottomMargin).isActive = true
        avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

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

        recordButton.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: actionButtonTopBottomMargin).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: recordButtonSize).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: recordButtonSize).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -actionButtonTopBottomMargin).isActive = true

        listenButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        listenButton.widthAnchor.constraint(equalToConstant: listenButtonSize).isActive = true
        listenButton.heightAnchor.constraint(equalToConstant: listenButtonSize).isActive = true
        listenButton.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -actionButtonsMargin).isActive = true

        replayButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        replayButton.widthAnchor.constraint(equalToConstant: replayButtonSize).isActive = true
        replayButton.heightAnchor.constraint(equalToConstant: replayButtonSize).isActive = true
        replayButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: actionButtonsMargin).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - Internal
    func setChapter(_ chapter: Chapter) {
        contentLabel.text = chapter.content
        contentPinyinLabel.text = chapter.contentPinyin
        contentInLocalLanguageLabel.text = chapter.contentInLocalLanguage
        audioURL = chapter.contentAudioURL
    }

    class func cellHeight(with width: CGFloat, chapter: Chapter) -> CGFloat {
        sizingCell.contentLabel.text = chapter.content
        sizingCell.contentPinyinLabel.text = chapter.contentPinyin
        sizingCell.contentInLocalLanguageLabel.text = chapter.contentInLocalLanguage
        var height = sizingCell.avatarViewSize + sizingCell.avatarViewTopBottomMargin * 2 + 2 * sizingCell.contentsMargin + sizingCell.actionLabelTopMargin + sizingCell.actionButtonTopBottomMargin * 2 + sizingCell.recordButtonSize
        let contentWidth = width - 2 * sizingCell.contentLeadingTrailingMargin
        height += sizingCell.contentLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        height += sizingCell.contentPinyinLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        height += sizingCell.contentInLocalLanguageLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        height += sizingCell.actionLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        return height
    }

    // MARK: - Private
    @objc func didTapListenButton() {
        listenButton.isSelected = true
        replayButton.isSelected = false
        recordButton.isSelected = false
        if audioURL != nil {
            let playerItem = AVPlayerItem.init(url: audioURL!)
            player = AVPlayer.init(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            player?.play()
        }
    }

    @objc func didTapRecordButton() {
        listenButton.isSelected = false
        replayButton.isSelected = false
        recordButton.isSelected = true
        if player?.timeControlStatus == .playing {
            player?.pause()
        }
    }

    @objc func playerDidFinishPlaying() {
        listenButton.isSelected = false
    }
}
