//
//  TrendingPhraseCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/26/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation
import Amplify

protocol TrendingPhraseCollectionViewCellDelegate: AnyObject {
    func didStartPlayAudio(with trendingPhraseWrapper: TrendingPhraseWrapper)
}

class TrendingPhraseCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private static let elementHorizontalMargin = CGFloat(18)
    private static let phraseLabelFontSize = CGFloat(20)
    private static let pinyinLabelFontSize = CGFloat(18)
    private static let explanationLabelFontSize = CGFloat(18)
    private static let labelToExplainMargin = CGFloat(10)
    private static let contentViewCornerRadius = CGFloat(8)
    private static let contentViewShadowRadius = CGFloat(6)
    private static let pinyinStackViewSpacing = CGFloat(4)
    private static let contentStackViewSpacing = CGFloat(4)
    private static let expandIconImageName = "chevron.down"
    private static let collapseIconImageName = "chevron.up"

    private static let pronounceSpeakerSize = CGFloat(25)
    private static let pronounceButtonImageName = "stories_speaker"

    // MARK: - Properties
    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [phraseLabel, pinyinStackView, explanationLabel])
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.distribution = .fill
        contentStackView.spacing = TrendingPhraseCollectionViewCell.contentStackViewSpacing
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        return contentStackView
    } ()

    private lazy var phraseLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .wisteriaPurple
        label.font = UIFont.init(name: "PingFangSC-Semibold", size: TrendingPhraseCollectionViewCell.phraseLabelFontSize)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    } ()

    private lazy var pinyinStackView: UIStackView = {
        let pinyinStackView = UIStackView.init(arrangedSubviews: [pinyinLabel, prounceButton])
        pinyinStackView.axis = .horizontal
        pinyinStackView.alignment = .center
        pinyinStackView.distribution = .fill
        pinyinStackView.spacing = TrendingPhraseCollectionViewCell.pinyinStackViewSpacing
        pinyinStackView.translatesAutoresizingMaskIntoConstraints = false
        return pinyinStackView
    } ()

    private lazy var pinyinLabel: UILabel = {
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
        button.addTarget(self, action: #selector(didTapPronounceButton), for: .touchUpInside)
        return button
    } ()

    private lazy var explanationLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        let fontDescriptor = UIFont.systemFont(ofSize: TrendingPhraseCollectionViewCell.explanationLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        label.numberOfLines = 0
        return label
    } ()

    private lazy var expandImageView: UIImageView = {
        let expandImageView = UIImageView.init(frame: .zero)
        expandImageView.translatesAutoresizingMaskIntoConstraints = false
        expandImageView.tintColor = .textBlueGray
        return expandImageView
    } ()

    private lazy var pinyinStackViewWidthAnchor: NSLayoutConstraint = {
        return pinyinStackView.widthAnchor.constraint(equalToConstant: 0)
    } ()

    // MARK: - Data
    private var player: AVPlayer?
    var trendingPhraseWrapper: TrendingPhraseWrapper? {
        didSet {
            guard let trendingPhraseWrapper = trendingPhraseWrapper else {
                return
            }
            let trendingPhrase = trendingPhraseWrapper.trendingPhrase
            let attributedPhrase = NSMutableAttributedString.init(string: "#" + trendingPhrase.content_zh + trendingPhrase.emoji)
            attributedPhrase.addAttributes([.foregroundColor : UIColor.wisteriaPurple], range: NSRange.init(location: 0, length: 1))
            attributedPhrase.addAttributes([.foregroundColor : UIColor.darkGrayTwo], range: NSRange.init(location: 1, length: attributedPhrase.length - 1))
            let emojiLength = trendingPhrase.emoji.count
            if let phraseLabelFont = UIFont.init(name: "PingFangSC-Medium", size: TrendingPhraseCollectionViewCell.phraseLabelFontSize) {
                attributedPhrase.addAttributes([.font : phraseLabelFont], range: NSRange.init(location: 0, length: attributedPhrase.length - 1 - emojiLength))
            }

            if emojiLength > 0 {
                attributedPhrase.addAttributes([ .font : UIFont.systemFont(ofSize: TrendingPhraseCollectionViewCell.phraseLabelFontSize)], range: NSRange.init(location: attributedPhrase.length - 1 - emojiLength, length: emojiLength))
            }
            phraseLabel.attributedText = attributedPhrase
            pinyinLabel.text = "/" + trendingPhrase.content_pinyin + "/  "
            explanationLabel.text = trendingPhrase.content_explanation
            if trendingPhraseWrapper.isExpanded {
                explanationLabel.isHidden = false
                let expandImage = UIImage.init(systemName: TrendingPhraseCollectionViewCell.collapseIconImageName)
                expandImageView.image = expandImage
            } else {
                explanationLabel.isHidden = true
                let expandImage = UIImage.init(systemName: TrendingPhraseCollectionViewCell.expandIconImageName)
                expandImageView.image = expandImage
            }
            let pinyinLabelMaxWidth = contentView.bounds.width - 2 * TrendingPhraseCollectionViewCell.elementHorizontalMargin - TrendingPhraseCollectionViewCell.pronounceSpeakerSize - TrendingPhraseCollectionViewCell.pinyinStackViewSpacing
            let pinyinLabelSize = pinyinLabel.sizeThatFits(CGSize.init(width: pinyinLabelMaxWidth, height: 0))
            pinyinStackViewWidthAnchor.constant = pinyinLabelSize.width + TrendingPhraseCollectionViewCell.pronounceSpeakerSize + TrendingPhraseCollectionViewCell.pinyinStackViewSpacing
            setNeedsUpdateConstraints()
        }
    }

    weak var delegate: TrendingPhraseCollectionViewCellDelegate?

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

        contentView.addSubview(contentStackView)
        contentView.addSubview(expandImageView)

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: TrendingPhraseCollectionViewCell.elementHorizontalMargin),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -TrendingPhraseCollectionViewCell.elementHorizontalMargin),
            contentStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            pinyinStackViewWidthAnchor,

            prounceButton.widthAnchor.constraint(equalToConstant: TrendingPhraseCollectionViewCell.pronounceSpeakerSize),
            prounceButton.heightAnchor.constraint(equalToConstant: TrendingPhraseCollectionViewCell.pronounceSpeakerSize),

            expandImageView.centerYAnchor.constraint(equalTo: phraseLabel.centerYAnchor),
            expandImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -TrendingPhraseCollectionViewCell.elementHorizontalMargin),
        ])
    }

    // MARK: - Private

    private func setupPronounceButton() {
        contentView.addSubview(prounceButton)

        prounceButton.leadingAnchor.constraint(equalTo: pinyinLabel.trailingAnchor).isActive = true
        prounceButton.centerYAnchor.constraint(equalTo: pinyinLabel.centerYAnchor).isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: TrendingPhraseCollectionViewCell.pronounceSpeakerSize).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: TrendingPhraseCollectionViewCell.pronounceSpeakerSize).isActive = true
    }


    @objc func didTapPronounceButton() {
        guard let audioKey = trendingPhraseWrapper?.trendingPhrase.audioKey?.key else {
            return
        }
        Amplify.Storage.getURL(key: audioKey) { event in
            switch event {
            case let .success(url):
                NewsAudioPlayer.shared.pauseAudio()
                let playerItem = AVPlayerItem.init(url: url)
                self.player = AVPlayer.init(playerItem: playerItem)
                self.player?.rate = AudioPlaySpeed.normal.rawValue
                self.player?.play()
                self.delegate?.didStartPlayAudio(with: self.trendingPhraseWrapper!)
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }
}
