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
    private let playButtonWidth = CGFloat(20)
    private let playButtonHeight = CGFloat(20)
    private let titleLabelFontSize = CGFloat(14)
    private let contentStackViewMargin = CGFloat(10)
    private let contentStackViewSpacing = CGFloat(10)
    private let cancelButtonWidth = CGFloat(20)
    private let cancelButtonHeight = CGFloat(20)
    private let intrinsicContentHeight = CGFloat(60)
    private let coverImageViewAlpha = CGFloat(0.52)

    var delegate: NewsPlayingNowViewDelegate?

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
        let cancelButtonImage = UIImage.init(systemName: "xmark")?.withTintColor(.textBlueGray)
        cancelButton.setImage(cancelButtonImage, for: .normal)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return cancelButton
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGray
        titleLabel.font = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold)
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [coverImageView, titleLabel, cancelButton])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.alignment = .center
        contentStackView.axis = .horizontal
        contentStackView.spacing = contentStackViewSpacing
        return contentStackView
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

        addSubview(contentStackView)
        addSubview(playButton)

        NSLayoutConstraint.activate([
            coverImageView.widthAnchor.constraint(equalToConstant: coverImageViewWidth),
            coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight),

            playButton.widthAnchor.constraint(equalToConstant: playButtonWidth),
            playButton.heightAnchor.constraint(equalToConstant: playButtonHeight),
            playButton.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor),

            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentStackViewMargin),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentStackViewMargin),
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            cancelButton.widthAnchor.constraint(equalToConstant: cancelButtonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: cancelButtonHeight)
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
}
