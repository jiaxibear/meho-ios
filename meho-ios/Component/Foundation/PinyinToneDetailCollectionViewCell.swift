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
    private let labelFontSize = CGFloat(15)
    private let speakerToSymbalMargin = CGFloat(10)
    private let pronounceButtonImageName = "stories_speaker"

    // MARK: - Properties
    private let prounceButton = UIButton.init(frame: .zero)
    private let symbolLabel = UILabel.init(frame: .zero)
    private let characterLabel = UILabel.init(frame: .zero)

    // MARK: - Data
    private var isFound = false
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
        let pronounceSpeakerImage = UIImage.init(named: pronounceButtonImageName)
        prounceButton.translatesAutoresizingMaskIntoConstraints = false
        prounceButton.setImage(pronounceSpeakerImage, for: UIControl.State.normal)
        prounceButton.setImage(pronounceSpeakerImage, for: UIControl.State.selected)
        prounceButton.addTarget(self, action: #selector(didTapPronounceButton), for: .touchUpInside)
        contentView.addSubview(prounceButton)

        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.textAlignment = .left
        symbolLabel.textColor = .textCharcoalGrey
        let labelEnFontDescriptor = UIFont.systemFont(ofSize: labelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        symbolLabel.font = UIFont.init(descriptor: labelEnFontDescriptor!, size: 0)
        contentView.addSubview(symbolLabel)

        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        characterLabel.textAlignment = .left
        characterLabel.textColor = .wisteriaPurple
        characterLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: labelFontSize)
        contentView.addSubview(characterLabel)
        characterLabel.isHidden = true

        prounceButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        prounceButton.widthAnchor.constraint(equalToConstant: contentView.bounds.height * 0.6).isActive = true
        prounceButton.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.6).isActive = true
        prounceButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        prounceButton.isHidden = true

        symbolLabel.leadingAnchor.constraint(equalTo: prounceButton.trailingAnchor, constant: speakerToSymbalMargin).isActive = true
        symbolLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width / 3).isActive = true
        symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        symbolLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        characterLabel.leadingAnchor.constraint(equalTo: symbolLabel.trailingAnchor).isActive = true
        characterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        characterLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        characterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

    }

    override func prepareForReuse() {
        prounceButton.isHidden = true
        symbolLabel.text = nil
        characterLabel.text = nil
    }

    func setDetailsFound(symbol: String, character: String, pronounceUrl: URL?) {
        isFound = true
        maybeToneAudioUrl = pronounceUrl
        symbolLabel.text = symbol
        characterLabel.text = character

        prounceButton.isHidden = false
        characterLabel.isHidden = false
    }

    func setDetailsNotFound(symbol: String) {
        isFound = false
        symbolLabel.text = symbol

        prounceButton.isHidden = true
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
