//
//  TrendingPhraseCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/26/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation


class TrendingPhraseCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private static let elementHorizontalMargin = CGFloat(18)
    private static let phraseLabelFontSize = CGFloat(20)
    private static let pinyinLabelFontSize = CGFloat(18)
    private static let explanationLabelFontSize = CGFloat(16)
    private static let labelToExplainMargin = CGFloat(10)
    private static let contentViewCornerRadius = CGFloat(8)
    private static let contentViewShadowRadius = CGFloat(6)

    private static let pronounceSpeakerSize = CGFloat(25)
    private static let cellVerticalMargin = CGFloat(7)
    private static let pronounceButtonImageName = "stories_speaker"

    // MARK: - Properties
    private lazy var phraseLabel:UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .wisteriaPurple
        label.font = UIFont.init(name: "PingFangSC-Semibold", size: TrendingPhraseCollectionViewCell.phraseLabelFontSize)
        label.numberOfLines = 1
        label.backgroundColor = .paleLilac
        return label
    } ()

    private lazy var pinyinLabel:UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .darkGray
        let pinyinfontDescriptor = UIFont.systemFont(ofSize: TrendingPhraseCollectionViewCell.pinyinLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: pinyinfontDescriptor!, size: 0)
        label.numberOfLines = 1
        return label
    } ()

    private lazy var prounceButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        let pronounceSpeakerImage = UIImage.init(named: TrendingPhraseCollectionViewCell.pronounceButtonImageName)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(pronounceSpeakerImage, for: UIControl.State.normal)
        button.setImage(pronounceSpeakerImage, for: UIControl.State.selected)
        button.addTarget(self, action: #selector(didTapPronounceButton), for: .touchUpInside)
        return button
    } ()

    private lazy var explanationLabel:UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        let fontDescriptor = UIFont.systemFont(ofSize: TrendingPhraseCollectionViewCell.explanationLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        label.numberOfLines = 0
        return label
    } ()

    private static var sizingCell = TrendingPhraseCollectionViewCell.init(frame: .zero);

    // MARK: - Data
    private var player: AVPlayer?
    private var maybePronounceAudioUrl: URL?


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
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
        layer.shadowRadius = TrendingPhraseCollectionViewCell.contentViewShadowRadius
        layer.backgroundColor = UIColor.clear.cgColor

        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.paleLilac.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = TrendingPhraseCollectionViewCell.contentViewCornerRadius
        contentView.backgroundColor = .white

        setupPhraseLabel()
        setupPinyinLabel()
        setupPronounceButton()
        setupExplanationLabel()

    }

    private func setupPhraseLabel() {
        contentView.addSubview(phraseLabel)

        phraseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: TrendingPhraseCollectionViewCell.elementHorizontalMargin).isActive = true
        phraseLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: TrendingPhraseCollectionViewCell.cellVerticalMargin).isActive = true
    }

    private func setupPinyinLabel() {
        contentView.addSubview(pinyinLabel)

        pinyinLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: TrendingPhraseCollectionViewCell.elementHorizontalMargin).isActive = true
        pinyinLabel.topAnchor.constraint(equalTo: phraseLabel.bottomAnchor, constant: TrendingPhraseCollectionViewCell.cellVerticalMargin).isActive = true
    }

    private func setupPronounceButton() {
        contentView.addSubview(prounceButton)

        prounceButton.leadingAnchor.constraint(equalTo: pinyinLabel.trailingAnchor).isActive = true
        prounceButton.centerYAnchor.constraint(equalTo: pinyinLabel.centerYAnchor).isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: TrendingPhraseCollectionViewCell.pronounceSpeakerSize).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: TrendingPhraseCollectionViewCell.pronounceSpeakerSize).isActive = true
    }

    private func setupExplanationLabel() {
        contentView.addSubview(explanationLabel)

        explanationLabel.topAnchor.constraint(equalTo: pinyinLabel.bottomAnchor, constant: TrendingPhraseCollectionViewCell.cellVerticalMargin).isActive = true
        explanationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -TrendingPhraseCollectionViewCell.cellVerticalMargin).isActive = true
        explanationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: TrendingPhraseCollectionViewCell.elementHorizontalMargin).isActive = true
        explanationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -TrendingPhraseCollectionViewCell.elementHorizontalMargin).isActive = true
    }

    // MARK: - Private
    @objc func didTapPronounceButton() {
        if let pronounceURL = maybePronounceAudioUrl {
            let playerItem = AVPlayerItem.init(url: pronounceURL)
            player = AVPlayer.init(playerItem: playerItem)
            player?.rate = AudioPlaySpeed.normal.rawValue
            player?.play()
        }
    }

    // MARK: - Public
    public func setPhrase(_ phrase: Phrase) {
        phraseLabel.text = " # " + phrase.content_zh + " "
        pinyinLabel.text = "/" + phrase.content_pinyin + "/  "
        explanationLabel.text = phrase.content_explanation
        maybePronounceAudioUrl = phrase.audioURL
    }

    public class func cellHeight(with width: CGFloat, phrase: Phrase) -> CGFloat {
        sizingCell.setPhrase(phrase)
        let height = TrendingPhraseCollectionViewCell.cellVerticalMargin * 4
            + sizingCell.phraseLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
            + sizingCell.pinyinLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
            + sizingCell.explanationLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
        return height
    }
}
