//
//  CompletedVocabularyCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 11/22/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVKit
import Amplify
import AmplifyPlugins

class CompletedVocabularyCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let vocabularyEnLabelTopMargin = CGFloat(5)
    private let pronounceButtonSize = CGFloat(25)
    private let pronounceButtonImageName = "stories_speaker"
    private let topLineStackViewSpacing = CGFloat(10)
    private let vocabularyZhLabelFontSize = CGFloat(20)
    private let vocabularyPinyinLabelFontSize = CGFloat(16)
    private let contentViewCornerRadius = CGFloat(8)
    private let contentViewShadowRadius = CGFloat(3)
    private let contentViewShadowSpread = CGFloat(2)
    private let contentTopBottomMargin = CGFloat(14)
    private let contentLeadingTrailingMargin = CGFloat(20)

    // MARK: - Properties
    private lazy var vocabularyZhLabel: UILabel = {
        let vocabularyZhLabel = UILabel.init(frame: .zero)
        vocabularyZhLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyZhLabel.numberOfLines = 1
        vocabularyZhLabel.textColor = .wisteriaPurple
        vocabularyZhLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: vocabularyZhLabelFontSize)
        return vocabularyZhLabel
    } ()

    private lazy var vocabularyPinyinLabel: UILabel = {
        let vocabularyPinyinLabel = UILabel.init(frame: .zero)
        vocabularyPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyPinyinLabel.textColor = .darkGrayTwo
        vocabularyPinyinLabel.numberOfLines = 1
        if let pinyinfontDescriptor = UIFont.systemFont(ofSize: vocabularyZhLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded) {
            vocabularyPinyinLabel.font = UIFont.init(descriptor: pinyinfontDescriptor, size: vocabularyZhLabelFontSize)
        }
        return vocabularyPinyinLabel
    } ()

    private lazy var vocabularyEnLabel: UILabel = {
        let vocabularyEnLabel = UILabel.init(frame: .zero)
        vocabularyEnLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyEnLabel.numberOfLines = 0
        vocabularyEnLabel.textColor = .darkGrayTwo
        if let enfontDescriptor = UIFont.systemFont(ofSize: vocabularyPinyinLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded) {
            vocabularyEnLabel.font = UIFont.init(descriptor: enfontDescriptor, size: vocabularyPinyinLabelFontSize)
        }
        return vocabularyEnLabel
    } ()

    private lazy var prounceButton: UIButton = {
        let prounceButton = UIButton.init(frame: .zero)
        let pronounceSpeakerImage = UIImage.init(named: pronounceButtonImageName)
        prounceButton.translatesAutoresizingMaskIntoConstraints = false
        prounceButton.setImage(pronounceSpeakerImage, for: UIControl.State.normal)
        prounceButton.addTarget(self, action: #selector(didTapPronounceButton), for: .touchUpInside)
        return prounceButton
    } ()

    private lazy var topLineStackView: UIStackView = {
        let topLineStackView = UIStackView.init(arrangedSubviews: [vocabularyZhLabel, vocabularyPinyinLabel, prounceButton])
        topLineStackView.translatesAutoresizingMaskIntoConstraints = false
        topLineStackView.axis = .horizontal
        topLineStackView.alignment = .center
        topLineStackView.spacing = topLineStackViewSpacing
        return topLineStackView
    } ()

    private lazy var topLineStackViewHeightConstraint: NSLayoutConstraint = {
        return topLineStackView.heightAnchor.constraint(equalToConstant: 0)
    } ()

    private lazy var vocabularyEnLabelHeightConstraint: NSLayoutConstraint = {
        var vocabularyEnLabelHeightConstraint = vocabularyEnLabel.heightAnchor.constraint(equalToConstant: 0)
        vocabularyEnLabelHeightConstraint.priority = .defaultHigh
        return vocabularyEnLabelHeightConstraint
    } ()

    private static var sizingCell = CompletedVocabularyCollectionViewCell.init(frame: .zero);

    // MARK: - Data
    private var player: AVPlayer?
    private var maybePronounceAudioUrl: URL?
    private var maybePronounceAudioBucket: String?
    private var maybePronounceAudioKey: String?

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.shadowColor = UIColor.paleLilac.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
        layer.shadowRadius = contentViewShadowRadius
        layer.shadowOpacity = 1.0
        layer.backgroundColor = UIColor.clear.cgColor

        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.paleLilac.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.backgroundColor = .white

        contentView.addSubview(topLineStackView)
        contentView.addSubview(vocabularyEnLabel)
        topLineStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentTopBottomMargin).isActive = true
        topLineStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        topLineStackViewHeightConstraint.isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: pronounceButtonSize).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: pronounceButtonSize).isActive = true
        vocabularyEnLabel.topAnchor.constraint(equalTo: topLineStackView.bottomAnchor, constant: vocabularyEnLabelTopMargin).isActive = true
        vocabularyEnLabel.leadingAnchor.constraint(equalTo: topLineStackView.leadingAnchor).isActive = true
        vocabularyEnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        vocabularyEnLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentTopBottomMargin).isActive = true
        vocabularyEnLabelHeightConstraint.isActive = true
    }

    // MARK: - Public
    public func setVocabulary(_ vocabulary: Vocabulary) {
        vocabularyZhLabel.text = vocabulary.content_zh
        vocabularyPinyinLabel.text = " /" + vocabulary.content_pinyin + "/  "
        var explanation = vocabulary.content_en
        if vocabulary.content_optional != "" {
            explanation = explanation + "\n" + vocabulary.content_optional
        }
        vocabularyEnLabel.text = explanation
        maybePronounceAudioUrl = vocabulary.audioURL
        maybePronounceAudioKey = vocabulary.audio_key
        maybePronounceAudioBucket = vocabulary.audio_bucket
        let contentFittingSize = self.contentFittingSize(with: contentView.bounds.width)
        topLineStackViewHeightConstraint.constant = max(vocabularyZhLabel.sizeThatFits(contentFittingSize).height, pronounceButtonSize)
        vocabularyEnLabelHeightConstraint.constant = vocabularyEnLabel.sizeThatFits(contentFittingSize).height
        setNeedsUpdateConstraints()
    }

    private func contentFittingSize(with width: CGFloat) -> CGSize {
        let contentWidth = width - 2 * contentLeadingTrailingMargin
        return CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)
    }

    // MARK: - Private
    @objc func didTapPronounceButton() {
        if let pronounceURL = maybePronounceAudioUrl {
            let playerItem = AVPlayerItem.init(url: pronounceURL)
            player = AVPlayer.init(playerItem: playerItem)
            player?.rate = AudioPlaySpeed.normal.rawValue
            player?.play()
        }
        if let audioKey = maybePronounceAudioKey {
            Amplify.Storage.getURL(key: audioKey) { event in
                switch event {
                case let .success(url):
                    let playerItem = AVPlayerItem.init(url: url)
                    self.player = AVPlayer.init(playerItem: playerItem)
                    self.player?.rate = AudioPlaySpeed.normal.rawValue
                    self.player?.play()
                case let .failure(storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
        }
    }
}
