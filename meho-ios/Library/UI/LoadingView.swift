//
//  LoadingView.swift
//  meho-ios
//
//  Created by Meho Dev on 2/23/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

enum LoadingViewState {
    case loading
    case empty
    case noConnection
}

protocol LoadingViewDelegate: AnyObject {
    func didTapRetyButton()
}

class LoadingView: UIView {

    // MARK: - Constants
    private let loadingImageViewWidth = CGFloat(200)
    private let loadingImageViewHeight = CGFloat(200)
    private let loadingImageViewTopMargin = CGFloat(120)
    private let loadingTitleLabelFontSize = CGFloat(20)
    private let emptyTitleLabelFontSize = CGFloat(30)
    private let emptySubtitleLabelFontSize = CGFloat(20)
    private let retryButtonFontSize = CGFloat(16)
    private let retryButtonCornerRadius = CGFloat(14)

    private let emptyStackViewLeadingTrailingMargin = CGFloat(40)
    private let emptyImageViewHeight = CGFloat(140)
    private let emptyTitleLabelTopMargin = CGFloat(80)
    private let emptySubtitleLabelTopMargin = CGFloat(40)
    private let retryButtonTopMargin = CGFloat(80)
    private let emptyLabelWidth = CGFloat(250)
    private let retryButtonWidth = CGFloat(210)
    private let retryButtonHeight = CGFloat(40)

    // MARK: - Properties
    private lazy var loadingImageView: UIImageView = {
        let loadingImageView = UIImageView.init(frame: .zero)
        loadingImageView.translatesAutoresizingMaskIntoConstraints = false
        loadingImageView.loadGifFromLocal(name: "Loading@3x")
        return loadingImageView
    } ()

    private lazy var loadingTitleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("LoadingText", comment: "")
        titleLabel.textColor = .slateGrey
        titleLabel.font = UIFont.systemFont(ofSize: loadingTitleLabelFontSize, weight: .light)
        return titleLabel
    } ()

    private lazy var loadingContainerView: UIView = {
        let loadingContainerView = UIView.init(frame: .zero)
        loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
        return loadingContainerView
    } ()

    private lazy var emptyStackView: UIStackView = {
        let emptyStackView = UIStackView.init(arrangedSubviews: [emptyImageView, emptyTitleLabel, emptySubtitleLabel, retryButton])
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.axis = .vertical
        emptyStackView.alignment = .center
        emptyStackView.setCustomSpacing(emptyTitleLabelTopMargin, after: emptyImageView)
        emptyStackView.setCustomSpacing(emptySubtitleLabelTopMargin, after: emptyTitleLabel)
        emptyStackView.setCustomSpacing(retryButtonTopMargin, after: emptySubtitleLabel)
        emptyStackView.isHidden = true
        return emptyStackView
    } ()

    private lazy var emptyStackViewHeightConstraint: NSLayoutConstraint = {
        return emptyStackView.heightAnchor.constraint(equalToConstant: 0)
    } ()

    private lazy var emptyImageView: UIImageView = {
        let emptyImageView = UIImageView.init(frame: .zero)
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.contentMode = .scaleAspectFit
        return emptyImageView
    } ()

    private lazy var emptyTitleLabel: UILabel = {
        let emptyTitleLabel = UILabel.init(frame: .zero)
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyTitleLabel.textColor = .darkGrayTwo
        emptyTitleLabel.numberOfLines = 0
        let emptyTitleLabelFont = UIFont.systemFont(ofSize: emptyTitleLabelFontSize, weight: .medium)
        if let emptyTitleLabelFontDescriptor = emptyTitleLabelFont.fontDescriptor.withDesign(.rounded) {
            emptyTitleLabel.font = UIFont.init(descriptor: emptyTitleLabelFontDescriptor, size: emptyTitleLabelFontSize)
        } else {
            emptyTitleLabel.font = emptyTitleLabelFont
        }
        emptyTitleLabel.textAlignment = .center
        return emptyTitleLabel
    } ()

    private lazy var emptySubtitleLabel: UILabel = {
        let emptySubtitleLabel = UILabel.init(frame: .zero)
        emptySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptySubtitleLabel.textColor = .slateGrey
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 0
        let emptySubtitleLabelFont = UIFont.systemFont(ofSize: emptySubtitleLabelFontSize, weight: .light)
        emptySubtitleLabel.font = emptySubtitleLabelFont
        emptySubtitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return emptySubtitleLabel
    } ()

    private lazy var retryButton: UIButton = {
        let retryButton = UIButton.init(frame: .zero)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.backgroundColor = .wisteriaPurple
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = retryButtonCornerRadius
        retryButton.layer.masksToBounds = true
        retryButton.setTitle(NSLocalizedString("RetryButtonTitle", comment: ""), for: .normal)
        let retryButtonFont = UIFont.systemFont(ofSize: retryButtonFontSize, weight: .semibold)
        if let retryButtonFontDescriptor = retryButtonFont.fontDescriptor.withDesign(.rounded) {
            retryButton.titleLabel?.font = UIFont.init(descriptor: retryButtonFontDescriptor, size: retryButtonFontSize)
        } else {
            retryButton.titleLabel?.font = retryButtonFont
        }
        retryButton.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
        return retryButton
    } ()

    var state: LoadingViewState = .empty {
        didSet {
            switch state {
            case .loading:
                loadingContainerView.isHidden = false
                emptyStackView.isHidden = true
            case .empty:
                loadingContainerView.isHidden = true
                emptyStackView.isHidden = false
                emptyImageView.image = UIImage.init(named: "empty_state_general_error")
                emptyTitleLabel.text = NSLocalizedString("emptyTitle", comment: "")
                emptySubtitleLabel.text = NSLocalizedString("emptySubtitle", comment: "")
                updateEmptyStackViewHeight()
            case .noConnection:
                loadingContainerView.isHidden = true
                emptyStackView.isHidden = false
                emptyImageView.image = UIImage.init(named: "empty_state_no_internet")
                emptyTitleLabel.text = NSLocalizedString("NoConnectionTitle", comment: "")
                emptySubtitleLabel.text = NSLocalizedString("NoConnectionSubtitle", comment: "")
                updateEmptyStackViewHeight()
            }
        }
    }

    var delegate: LoadingViewDelegate?

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

        addSubview(loadingContainerView)
        addSubview(emptyStackView)
        loadingContainerView.addSubview(loadingImageView)
        loadingContainerView.addSubview(loadingTitleLabel)
        let layoutGuide = UILayoutGuide.init()
        addLayoutGuide(layoutGuide)
        updateEmptyStackViewHeight()

        NSLayoutConstraint.activate([
            loadingImageView.widthAnchor.constraint(equalToConstant: loadingImageViewWidth),
            loadingImageView.heightAnchor.constraint(equalToConstant: loadingImageViewHeight),
            loadingImageView.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
            loadingImageView.topAnchor.constraint(equalTo: loadingContainerView.topAnchor, constant: loadingImageViewTopMargin),

            loadingContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingContainerView.topAnchor.constraint(equalTo: topAnchor),
            loadingContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            layoutGuide.topAnchor.constraint(equalTo: loadingImageView.bottomAnchor),
            layoutGuide.bottomAnchor.constraint(equalTo: loadingContainerView.bottomAnchor),
            layoutGuide.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor),
            layoutGuide.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor),

            loadingTitleLabel.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            loadingTitleLabel.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),

            emptyStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: emptyStackViewLeadingTrailingMargin),
            emptyStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -emptyStackViewLeadingTrailingMargin),
            emptyStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyStackViewHeightConstraint,

            emptyImageView.heightAnchor.constraint(equalToConstant: emptyImageViewHeight),
            emptyTitleLabel.widthAnchor.constraint(equalToConstant: emptyLabelWidth),
            retryButton.widthAnchor.constraint(equalToConstant: retryButtonWidth),
            retryButton.heightAnchor.constraint(equalToConstant: retryButtonHeight),
        ])
    }

    // MARK: - Private
    private func updateEmptyStackViewHeight() {
        var height = emptyImageViewHeight + emptyTitleLabelTopMargin + emptySubtitleLabelTopMargin + retryButtonHeight + retryButtonTopMargin
        let labelFittingSize = CGSize.init(width: emptyLabelWidth, height: .greatestFiniteMagnitude)
        let emptyTitleLabelHeight = emptyTitleLabel.sizeThatFits(labelFittingSize).height
        let emptySubtitleLabelHeight = emptySubtitleLabel.sizeThatFits(labelFittingSize).height
        height = height + emptyTitleLabelHeight + emptySubtitleLabelHeight
        emptyStackViewHeightConstraint.constant = height
    }

    @objc
    private func didTapRetryButton() {
        delegate?.didTapRetyButton()
    }
}
