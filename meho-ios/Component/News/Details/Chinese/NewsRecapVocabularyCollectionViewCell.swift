//
//  NewsRecapVocabularyCollectionViewCell.swift
//  meho-ios
//  Holds UI logic for showing
//
//  Created by Jiaxi Xiong on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
import Amplify
import AmplifyPlugins

class NewsRecapVocabularyCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let labelFontSize = CGFloat(18)
    private let vocabularyEnLabelTopMargin = CGFloat(10)
    private let pronounceSpeakerSize = CGFloat(25)
    private let pronounceButtonImageName = "stories_speaker"

    // MARK: - Properties
    private lazy var vocabularyZhLabel: UILabel = {
        let vocabularyZhLabel = UILabel.init(frame: .zero)
        vocabularyZhLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyZhLabel.numberOfLines = 1
        vocabularyZhLabel.textColor = .darkGray
        vocabularyZhLabel.font = UIFont.init(name: "PingFangSC-Medium", size: labelFontSize)
        return vocabularyZhLabel
    } ()

    private lazy var vocabularyPinyinLabel: UILabel = {
        let vocabularyPinyinLabel = UILabel.init(frame: .zero)
        vocabularyPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyPinyinLabel.textColor = .darkGrayTwo
        vocabularyPinyinLabel.numberOfLines = 1
        if let pinyinfontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded) {
            vocabularyPinyinLabel.font = UIFont.init(descriptor: pinyinfontDescriptor, size: labelFontSize)
        }
        return vocabularyPinyinLabel
    } ()

    private lazy var vocabularyEnLabel: UILabel = {
        let vocabularyEnLabel = UILabel.init(frame: .zero)
        vocabularyEnLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyEnLabel.numberOfLines = 0
        if let enfontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded) {
            vocabularyEnLabel.font = UIFont.init(descriptor: enfontDescriptor, size: 0)
        }
        vocabularyEnLabel.textColor = .textBlueGray
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
        return topLineStackView
    } ()

    private lazy var topLineStackViewHeightAnchor: NSLayoutConstraint = {
        return topLineStackView.heightAnchor.constraint(equalToConstant: 0)
    } ()

    private static var sizingCell = NewsRecapVocabularyCollectionViewCell.init(frame: .zero);

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

        contentView.addSubview(topLineStackView)
        contentView.addSubview(vocabularyEnLabel)
        topLineStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        topLineStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        topLineStackViewHeightAnchor.isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: pronounceSpeakerSize).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: pronounceSpeakerSize).isActive = true
        vocabularyEnLabel.topAnchor.constraint(equalTo: topLineStackView.bottomAnchor, constant: vocabularyEnLabelTopMargin).isActive = true
        vocabularyEnLabel.leadingAnchor.constraint(equalTo: topLineStackView.leadingAnchor).isActive = true
        vocabularyEnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        vocabularyEnLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
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
        topLineStackViewHeightAnchor.constant = max(vocabularyZhLabel.sizeThatFits(contentFittingSize).height, pronounceSpeakerSize)
        setNeedsUpdateConstraints()
    }

    public class func cellHeight(with width: CGFloat, vocabulary: Vocabulary) -> CGFloat {
        sizingCell.setVocabulary(vocabulary)
        var height = sizingCell.vocabularyEnLabelTopMargin
        let contentFittingSize = sizingCell.contentFittingSize(with: width)
        height += max(sizingCell.vocabularyZhLabel.sizeThatFits(contentFittingSize).height, sizingCell.pronounceSpeakerSize)
        height += sizingCell.vocabularyEnLabel.sizeThatFits(contentFittingSize).height
        return height
    }

    private func contentFittingSize(with width: CGFloat) -> CGSize {
        return CGSize.init(width: width, height: .greatestFiniteMagnitude)
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
