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

class NewsRecapVocabularyCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    let labelFontSize = CGFloat(18)
    let labelToExplainMargin = CGFloat(10)
    let pronounceSpeakerSize = CGFloat(25)
    private let pronounceButtonImageName = "stories_speaker"

    // MARK: - Properties
    let vocabularyZhLabel = UILabel.init(frame: .zero)
    let vocabularyPinyinLabel = UILabel.init(frame: .zero)
    let vocabularyEnLabel = UILabel.init(frame: .zero)
    let prounceButton = UIButton.init(frame: .zero)

    private static var sizingCell = NewsRecapVocabularyCollectionViewCell.init(frame: .zero);


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

        setupZhLabel()
        setupPinyinLabel()
        setupPronounceButton()
        setupeEnLabel()

    }

    func setupZhLabel() {
        vocabularyZhLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyZhLabel.textColor = .darkGrayTwo
        vocabularyZhLabel.font = UIFont.init(name: "PingFangSC-Medium", size: labelFontSize)
        vocabularyZhLabel.numberOfLines = 1
        contentView.addSubview(vocabularyZhLabel)

        vocabularyZhLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        vocabularyZhLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    }

    func setupPinyinLabel() {
        vocabularyPinyinLabel.translatesAutoresizingMaskIntoConstraints = false

        vocabularyPinyinLabel.textColor = .darkGrayTwo
        let pinyinfontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        vocabularyPinyinLabel.font = UIFont.init(descriptor: pinyinfontDescriptor!, size: 0)
        vocabularyPinyinLabel.numberOfLines = 1
        contentView.addSubview(vocabularyPinyinLabel)

        vocabularyPinyinLabel.leadingAnchor.constraint(equalTo: vocabularyZhLabel.trailingAnchor).isActive = true
        vocabularyPinyinLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    }

    func setupPronounceButton() {
        let pronounceSpeakerImage = UIImage.init(named: pronounceButtonImageName)
        prounceButton.translatesAutoresizingMaskIntoConstraints = false
        prounceButton.setImage(pronounceSpeakerImage, for: UIControl.State.normal)
        prounceButton.setImage(pronounceSpeakerImage, for: UIControl.State.selected)
        prounceButton.addTarget(self, action: #selector(didTapPronounceButton), for: .touchUpInside)
        contentView.addSubview(prounceButton)

        prounceButton.leadingAnchor.constraint(equalTo: vocabularyPinyinLabel.trailingAnchor).isActive = true
        prounceButton.centerYAnchor.constraint(equalTo: vocabularyPinyinLabel.centerYAnchor).isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: pronounceSpeakerSize).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: pronounceSpeakerSize).isActive = true
    }

    func setupeEnLabel() {
        vocabularyEnLabel.translatesAutoresizingMaskIntoConstraints = false
        vocabularyEnLabel.textColor = .textBlueGray
        let enfontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        vocabularyEnLabel.font = UIFont.init(descriptor: enfontDescriptor!, size: 0)
        vocabularyEnLabel.numberOfLines = 1
        contentView.addSubview(vocabularyEnLabel)


        vocabularyEnLabel.topAnchor.constraint(equalTo: vocabularyZhLabel.bottomAnchor, constant: labelToExplainMargin).isActive = true
        vocabularyEnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    }


    // MARK: - Public
    public func setVocabulary(_ vocabulary: Vocabulary) {
        vocabularyZhLabel.text = vocabulary.content_zh
        vocabularyPinyinLabel.text = " /" + vocabulary.content_pinyin + "/  "
        vocabularyEnLabel.text = vocabulary.content_en
        maybePronounceAudioUrl = vocabulary.audioURL

    }

    public class func cellHeight(with width: CGFloat, vocabulary: Vocabulary) -> CGFloat {
        sizingCell.setVocabulary(vocabulary)
        let height = sizingCell.labelToExplainMargin
            + sizingCell.vocabularyEnLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
            + sizingCell.vocabularyZhLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
        return height
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
}
