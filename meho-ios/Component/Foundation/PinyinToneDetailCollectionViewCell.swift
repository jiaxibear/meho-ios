//
//  PinyinToneDetailCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/19/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation

class PinyinToneDetailCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let cardRadius = CGFloat(10)
    private let cardBorderwidth = CGFloat(2)
    private let labelFontSize = CGFloat(17)
    private let speakerToSymbalMargin = CGFloat(10)
    private let enabledeSpeakerImageName = "stories_speaker"
    private let disabledeSpeakerImageName = "speaker_disabled"

    // MARK: - Properties
    private let prounceButton = UIButton.init(frame: .zero)
    private let symbolLabel = UILabel.init(frame: .zero)
    private let characterLabel = UILabel.init(frame: .zero)

    // MARK: - Data
    private var maybeToneAudioUrl: URL?
    private var player: AVPlayer?

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
        // Sets up elements in the cell
        prounceButton.translatesAutoresizingMaskIntoConstraints = false
        prounceButton.addTarget(self, action: #selector(didTapPronounceButton), for: .touchUpInside)
        contentView.addSubview(prounceButton)

        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.textAlignment = .left
        symbolLabel.textColor = .textCharcoalGrey
        let labelEnFontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        symbolLabel.font = UIFont.init(descriptor: labelEnFontDescriptor!, size: 0)
        symbolLabel.sizeToFit()
        contentView.addSubview(symbolLabel)

        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        characterLabel.textAlignment = .left
        characterLabel.textColor = .wisteriaPurple
        characterLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: labelFontSize)
        contentView.addSubview(characterLabel)
        characterLabel.sizeToFit()
        characterLabel.textAlignment = .left
        characterLabel.isHidden = true

        prounceButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: contentView.bounds.height * 0.6).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.6).isActive = true
        prounceButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        symbolLabel.leadingAnchor.constraint(equalTo: prounceButton.trailingAnchor, constant: speakerToSymbalMargin).isActive = true
        symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        symbolLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        characterLabel.leadingAnchor.constraint(equalTo: symbolLabel.trailingAnchor).isActive = true
        characterLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        characterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

    }

    override func prepareForReuse() {
        symbolLabel.text = nil
        characterLabel.text = nil
    }

    func setDetailsFound(symbol: String, character: String, pronounceUrl: URL?) {
        maybeToneAudioUrl = pronounceUrl
        symbolLabel.text = "/" + symbol + "/ "
        symbolLabel.textColor = .textCharcoalGrey
        characterLabel.text = character

        let enabledeSpeakerImage = UIImage.init(named: enabledeSpeakerImageName)
        prounceButton.setImage(enabledeSpeakerImage, for: UIControl.State.normal)
        prounceButton.isUserInteractionEnabled = true
        characterLabel.isHidden = false
    }

    func setDetailsNotFound(symbol: String) {
        symbolLabel.text = "/" + symbol + "/ "
        symbolLabel.textColor = .textBlueGray

        let disabledeSpeakerImage = UIImage.init(named: disabledeSpeakerImageName)
        prounceButton.isUserInteractionEnabled = false
        prounceButton.setImage(disabledeSpeakerImage, for: UIControl.State.normal)
        characterLabel.isHidden = true
    }


    // MARK: - Private
    @objc func didTapPronounceButton() {
        if let audioURL = maybeToneAudioUrl {
            let playerItem = AVPlayerItem.init(url: audioURL)
            player = AVPlayer.init(playerItem: playerItem)
            player?.rate = AudioPlaySpeed.normal.rawValue
            player?.play()
        }
    }
}
