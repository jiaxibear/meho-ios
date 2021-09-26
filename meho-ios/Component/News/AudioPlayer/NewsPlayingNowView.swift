//
//  NewsPlayingNowView.swift
//  meho-ios
//
//  Created by Meho Dev on 2/4/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

protocol NewsPlayingNowViewDelegate: AnyObject {
    func didTapCancelButton()
}

class NewsPlayingNowView: UIView {

    private let coverImageViewWidth = CGFloat(44)
    private let coverImageViewHeight = CGFloat(44)
    private let coverImageViewLeadingMargin = CGFloat(16)
    private let playButtonWidth = CGFloat(20)
    private let playButtonHeight = CGFloat(20)
    private let titleLabelFontSize = CGFloat(14)
    private let titleLabelLeadingMargin = CGFloat(8)
    private let titleLabelTrailingMargin = CGFloat(24)
    private let titleLabelTopMargin = CGFloat(10)
    private let cancelButtonWidth = CGFloat(20)
    private let cancelButtonHeight = CGFloat(20)
    private let cancelButtonHeightTrailingMargin = CGFloat(10)
    private let cancelButtonHeightTopMargin = CGFloat(10)
    private let intrinsicContentHeight = CGFloat(80)
    private let coverImageViewAlpha = CGFloat(0.52)
    private let speedButtonFontSize = CGFloat(15)
    private let actionButtonWidth = CGFloat(30)
    private let actionButtonHeight = CGFloat(30)
    private let buttonsStackViewLeadingTrailingMargin = CGFloat(34)
    private let buttonsStackViewLeadingBottomMargin = CGFloat(14)

    var delegate: NewsPlayingNowViewDelegate?
    private var currentAudioPlaySpeed = AudioPlaySpeed.normal

    var title: String {
        didSet {
            titleLabel.text = title
        }
    }

    var coverImageKey: S3ResourceKey? {
        didSet {
            coverImageView.imageKey = coverImageKey
        }
    }

    var isPlaying = true {
        didSet {
            if isPlaying {
                let playButtonImage = UIImage.init(systemName: "pause.fill")?.withTintColor(.skyBlue)
                playButton.setImage(playButtonImage, for: .normal)
            } else {
                let playButtonImage = UIImage.init(systemName: "play.fill")?.withTintColor(.skyBlue)
                playButton.setImage(playButtonImage, for: .normal)
            }
        }
    }

    private lazy var coverImageView: WebImageView = {
        let coverImageView = WebImageView.init(frame: .zero)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.layer.cornerRadius = coverImageViewWidth / 2
        coverImageView.layer.masksToBounds = true
        coverImageView.alpha = coverImageViewAlpha
        return coverImageView
    } ()

    private lazy var playButton: UIButton = {
        let playButton = UIButton.init(frame: .zero)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        let playButtonImage = UIImage.init(systemName: "pause.fill")?.withTintColor(.skyBlue)
        playButton.setImage(playButtonImage, for: .normal)
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        return playButton
    } ()

    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton.init(frame: .zero)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let cancelButtonImage = UIImage.init(systemName: "xmark")?.withTintColor(.darkGrayTwo, renderingMode: .alwaysOriginal)
        cancelButton.setImage(cancelButtonImage, for: .normal)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return cancelButton
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGray
        titleLabel.font = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold)
        titleLabel.numberOfLines = 1
        return titleLabel
    } ()

    private lazy var rewindButton: UIButton = {
        let rewindButton = UIButton.init()
        rewindButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage.init(named: "stories_audio_backward_10s")
        rewindButton.setImage(image, for: .normal)
        rewindButton.addTarget(self, action: #selector(didTapRewindButton), for: .touchUpInside)
        return rewindButton;
    } ()

    private lazy var forwardButton: UIButton = {
        let forwardButton = UIButton.init()
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage.init(named: "stories_audio_forward_10s")
        forwardButton.setImage(image, for: .normal)
        forwardButton.addTarget(self, action: #selector(didTapForwardButton), for: .touchUpInside)
        return forwardButton;
    } ()

    private lazy var speedButton: UIButton = {
        let speedButton = UIButton.init(frame: .zero)
        speedButton.translatesAutoresizingMaskIntoConstraints = false
        speedButton.setTitleColor(.darkGrayTwo, for: .normal)
        speedButton.setTitle(AudioPlaySpeed.normal.displayString(), for: .normal)
        var speedButtonFont = UIFont.systemFont(ofSize: speedButtonFontSize, weight: .medium)
        if let speedButtonFontDescriptor = speedButtonFont.fontDescriptor.withDesign(.rounded) {
            speedButtonFont = UIFont.init(descriptor: speedButtonFontDescriptor, size: speedButtonFontSize)
        }
        speedButton.titleLabel?.font = speedButtonFont
        speedButton.titleLabel?.textAlignment = .center
        speedButton.addTarget(self, action: #selector(didTapSpeedButton), for: .touchUpInside)
        return speedButton
    } ()

    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView.init(arrangedSubviews: [rewindButton, speedButton, forwardButton])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        return buttonsStackView
    } ()

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(news: News)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(news: News)")
    }

    init(title: String, coverImageKey: S3ResourceKey?) {
        self.title = title
        self.coverImageKey = coverImageKey
        super.init(frame: .zero)

        titleLabel.text = title
        coverImageView.imageKey = coverImageKey
        backgroundColor = .paleGray

        addSubview(buttonsStackView)
        addSubview(playButton)
        addSubview(coverImageView)
        addSubview(cancelButton)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            coverImageView.widthAnchor.constraint(equalToConstant: coverImageViewWidth),
            coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight),
            coverImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: coverImageViewLeadingMargin),

            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: titleLabelLeadingMargin),
            titleLabel.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -titleLabelTrailingMargin),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLabelTopMargin),

            buttonsStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: buttonsStackViewLeadingTrailingMargin),
            buttonsStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -buttonsStackViewLeadingTrailingMargin),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -buttonsStackViewLeadingBottomMargin),

            playButton.widthAnchor.constraint(equalToConstant: playButtonWidth),
            playButton.heightAnchor.constraint(equalToConstant: playButtonHeight),
            playButton.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor),

            cancelButton.widthAnchor.constraint(equalToConstant: cancelButtonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: cancelButtonHeight),
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: cancelButtonHeightTopMargin),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -cancelButtonHeightTrailingMargin),

            rewindButton.widthAnchor.constraint(equalToConstant: actionButtonWidth),
            rewindButton.heightAnchor.constraint(equalToConstant: actionButtonHeight),

            forwardButton.widthAnchor.constraint(equalToConstant: actionButtonWidth),
            forwardButton.heightAnchor.constraint(equalToConstant: actionButtonHeight),
        ])
    }

    // MARK: - UIView
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: intrinsicContentHeight)
    }

    // MARK: - Private
    @objc
    private func didTapCancelButton() {
        NewsAudioPlayer.shared.status = .notStarted
        delegate?.didTapCancelButton()
    }

    @objc
    private func didTapPlayButton() {
        let newsAudioPlayer = NewsAudioPlayer.shared
        switch newsAudioPlayer.status {
        case .playing:
            newsAudioPlayer.status = .paused
            break
        case .paused:
            newsAudioPlayer.status = .playing
            break
        case .notStarted:
            break
        }
    }

    @objc func didTapRewindButton() {
        let newsAudioPlayer = NewsAudioPlayer.shared
        newsAudioPlayer.rewind()
    }

    @objc func didTapForwardButton() {
        let newsAudioPlayer = NewsAudioPlayer.shared
        newsAudioPlayer.forward()
    }

    @objc func didTapSpeedButton() {
        currentAudioPlaySpeed = currentAudioPlaySpeed.next()
        speedButton.setTitle(currentAudioPlaySpeed.displayString(), for: .normal)
        let newsAudioPlayer = NewsAudioPlayer.shared
        newsAudioPlayer.changeRate(rate: currentAudioPlaySpeed.rawValue)
    }
}
