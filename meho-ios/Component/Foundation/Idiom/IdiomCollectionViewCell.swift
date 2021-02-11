//
//  IdiomCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAnalytics

protocol IdiomCollectionViewCellDelegate: AnyObject {
    func idiomCollectionViewCellDidTapPlayButton(idiom: Idiom)
}

class IdiomCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let wordLabelFontSize = CGFloat(18)
    private let titleLabelFontSize = CGFloat(20)
    private let playAudioButtonWidth = CGFloat(36)
    private let playAudioButtonHeight = CGFloat(36)
    private let titleStackViewSpacing = CGFloat(16)
    private let contentStackViewLeadingTrailingMargin = CGFloat(18)
    private let contentStackViewBottomMargin = CGFloat(50)
    private let explanationLabelTopBottomMargin = CGFloat(12)
    private let wordLabelMargin = CGFloat(4)
    private let wordStackViewSpacing = CGFloat(4)

    // MARK: - Properties
    weak var delegate: IdiomCollectionViewCellDelegate?
    private var audioURL: URL?
    private var player: AVPlayer?
    private var idiom: Idiom!
    private lazy var backgroundImageView: WebImageView = {
        let backgroundImageView = WebImageView.init(frame: .zero)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImageView
    } ()

    private lazy var firstWordExplanationLabel: UILabel = {
        let wordExplanationLabel = UILabel.init(frame: .zero)
        wordExplanationLabel.translatesAutoresizingMaskIntoConstraints = false
        wordExplanationLabel.textColor = .darkGrayTwo
        let wordExplanationLabelFontDescriptor = UIFont.systemFont(ofSize: wordLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        wordExplanationLabel.font = UIFont.init(descriptor: wordExplanationLabelFontDescriptor!, size: wordLabelFontSize)
        wordExplanationLabel.numberOfLines = 0
        return wordExplanationLabel
    } ()

    private lazy var secondWordExplanationLabel: UILabel = {
        let wordExplanationLabel = UILabel.init(frame: .zero)
        wordExplanationLabel.translatesAutoresizingMaskIntoConstraints = false
        wordExplanationLabel.textColor = .darkGrayTwo
        let wordExplanationLabelFontDescriptor = UIFont.systemFont(ofSize: wordLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        wordExplanationLabel.font = UIFont.init(descriptor: wordExplanationLabelFontDescriptor!, size: wordLabelFontSize)
        wordExplanationLabel.numberOfLines = 0
        return wordExplanationLabel
    } ()

    private lazy var thirdWordExplanationLabel: UILabel = {
        let wordExplanationLabel = UILabel.init(frame: .zero)
        wordExplanationLabel.translatesAutoresizingMaskIntoConstraints = false
        wordExplanationLabel.textColor = .darkGrayTwo
        let wordExplanationLabelFontDescriptor = UIFont.systemFont(ofSize: wordLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        wordExplanationLabel.font = UIFont.init(descriptor: wordExplanationLabelFontDescriptor!, size: wordLabelFontSize)
        wordExplanationLabel.numberOfLines = 0
        return wordExplanationLabel
    } ()

    private lazy var fourthWordExplanationLabel: UILabel = {
        let wordExplanationLabel = UILabel.init(frame: .zero)
        wordExplanationLabel.translatesAutoresizingMaskIntoConstraints = false
        wordExplanationLabel.textColor = .darkGrayTwo
        let wordExplanationLabelFontDescriptor = UIFont.systemFont(ofSize: wordLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        wordExplanationLabel.font = UIFont.init(descriptor: wordExplanationLabelFontDescriptor!, size: wordLabelFontSize)
        wordExplanationLabel.numberOfLines = 0
        return wordExplanationLabel
    } ()

    private lazy var playAudioButton: UIButton = {
        let playAudioButton = UIButton.init(frame: .zero)
        playAudioButton.layer.cornerRadius = playAudioButtonWidth / 2
        playAudioButton.clipsToBounds = true
        let playAudioButtonImage = UIImage.init(named: "stories_speaker")
        playAudioButton.setBackgroundImage(playAudioButtonImage, for: .normal)
        playAudioButton.addTarget(self, action: #selector(didTapPlayAudioButton), for: .touchUpInside)
        return playAudioButton
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .mehoDarkGray
        titleLabel.font = UIFont.init(name: "PingFangSC-Medium", size: titleLabelFontSize)
        return titleLabel
    } ()

    private lazy var titleStackView: UIStackView = {
        let titleStackView = UIStackView.init(arrangedSubviews: [playAudioButton, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        titleStackView.spacing = titleStackViewSpacing
        return titleStackView
    } ()

    private lazy var explanationLabel: UILabel = {
        let explanationLabel = UILabel.init(frame: .zero)
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.textColor = .darkGrayTwo
        let explanationLabelFontDescriptor = UIFont.systemFont(ofSize: wordLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        explanationLabel.font = UIFont.init(descriptor: explanationLabelFontDescriptor!, size: wordLabelFontSize)
        explanationLabel.numberOfLines = 0
        return explanationLabel
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [titleStackView, explanationLabel, firstWordExplanationLabel, secondWordExplanationLabel, thirdWordExplanationLabel, fourthWordExplanationLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.setCustomSpacing(explanationLabelTopBottomMargin, after: titleStackView)
        contentStackView.setCustomSpacing(explanationLabelTopBottomMargin, after: explanationLabel)
        contentStackView.setCustomSpacing(wordStackViewSpacing, after: firstWordExplanationLabel)
        contentStackView.setCustomSpacing(wordStackViewSpacing, after: secondWordExplanationLabel)
        contentStackView.setCustomSpacing(wordStackViewSpacing, after: thirdWordExplanationLabel)
        return contentStackView
    } ()

    private lazy var titleStackViewHeightAnchor: NSLayoutConstraint = {
        return titleStackView.heightAnchor.constraint(equalToConstant: 0)
    } ()

    private lazy var contentStackViewHeightAnchor: NSLayoutConstraint = {
        return contentStackView.heightAnchor.constraint(equalToConstant: 0)
    } ()

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

        contentView.addSubview(backgroundImageView)
        contentView.addSubview(contentStackView)

        backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        playAudioButton.widthAnchor.constraint(equalToConstant: playAudioButtonWidth).isActive = true
        playAudioButton.heightAnchor.constraint(equalToConstant: playAudioButtonHeight).isActive = true

        contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentStackViewLeadingTrailingMargin).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentStackViewLeadingTrailingMargin).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentStackViewBottomMargin).isActive = true
    }

    // MARK: - Internal
    func setIdiom(_ idiom: Idiom) {
        self.idiom = idiom
        backgroundImageView.imageURL = idiom.backgroundImageURL
        titleLabel.text = idiom.title
        explanationLabel.text = idiom.explanation
        firstWordExplanationLabel.text = idiom.firstWord + " " + idiom.firstWordExplanation
        secondWordExplanationLabel.text = idiom.secondWord + " " + idiom.secondWordExplanation
        thirdWordExplanationLabel.text = idiom.thirdWord + " " + idiom.thirdWordExplanation
        fourthWordExplanationLabel.text = idiom.fourthWord + " " + idiom.fourthWordExplanation
        audioURL = idiom.audioURL

        let labelMaxWidth = contentStackView.bounds.width
        let labelFittingSize = CGSize.init(width: labelMaxWidth, height: .greatestFiniteMagnitude)
        let titleStackViewHeight = max(playAudioButtonHeight, titleLabel.sizeThatFits(labelFittingSize).height)
        titleStackViewHeightAnchor.constant = titleStackViewHeight
        titleStackViewHeightAnchor.isActive = true
        let explanationLabelHeight = explanationLabel.sizeThatFits(labelFittingSize).height
        let firstWordStackViewHeight = firstWordExplanationLabel.sizeThatFits(labelFittingSize).height
        let secondWordStackViewHeight = secondWordExplanationLabel.sizeThatFits(labelFittingSize).height
        let thirdWordStackViewHeight = thirdWordExplanationLabel.sizeThatFits(labelFittingSize).height
        let fourthWordStackViewHeight = fourthWordExplanationLabel.sizeThatFits(labelFittingSize).height
        let contentStackViewHeight = titleStackViewHeight + explanationLabelHeight + firstWordStackViewHeight + secondWordStackViewHeight + thirdWordStackViewHeight + fourthWordStackViewHeight + explanationLabelTopBottomMargin * 2 + wordLabelMargin * 3
        contentStackViewHeightAnchor.constant = contentStackViewHeight
        contentStackViewHeightAnchor.isActive = true
    }

    // MARK: - Private
    @objc
    func didTapPlayAudioButton() {
        if audioURL != nil {
            NewsAudioPlayer.shared.pauseAudio()
            let playerItem = AVPlayerItem.init(url: audioURL!)
            player = AVPlayer.init(playerItem: playerItem)
            player!.rate = AudioPlaySpeed.normal.rawValue
            player!.play()
            delegate?.idiomCollectionViewCellDidTapPlayButton(idiom: idiom)
        }
    }
}
