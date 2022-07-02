//
//  PandaOnboardingContentView.swift
//  meho-ios
//
//  Created by Meho Dev on 6/26/22.
//  Copyright © 2022 Meho. All rights reserved.
//

import UIKit
import Network
import Instructions

class PandaOnboardingContentView: UIView, CoachMarkBodyView {

    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(22)
    private let subtitleLabelFontSize = CGFloat(14)
    private let titlesStackViewHeight = CGFloat(90)
    private let closeButtonWidth = CGFloat(20)
    private let closeButtonHeight = CGFloat(20)
    private let closeButtonTopMargin = CGFloat(10)
    private let closeButtonTrailingMargin = CGFloat(10)
    private let pandaImageViewWidth = CGFloat(150)
    private let pandaImageViewHeight = CGFloat(150)
    private let pandaImageViewCustomSpacing = CGFloat(20)
    private let mainActionLabelFontSize = CGFloat(16)
    private let contentStackViewTopBottomMargin = CGFloat(16)
    private let contentStackViewLeadingTrailingMargin = CGFloat(36)
    private let viewCornerRadius = CGFloat(8)
    private let bulletPointViewFontSize = CGFloat(14)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        var titleLabelFont = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium)
        if let titleLabelFontDescriptor = titleLabelFont.fontDescriptor.withDesign(.rounded) {
            titleLabelFont = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        }
        titleLabel.font = titleLabelFont
        titleLabel.textAlignment = .center
        return titleLabel
    } ()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel.init(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = .darkGrayTwo
        var subtitleLabelFont = UIFont.systemFont(ofSize: subtitleLabelFontSize, weight: .semibold)
        if let subtitleLabelFontDescriptor = subtitleLabelFont.fontDescriptor.withDesign(.rounded) {
            subtitleLabelFont = UIFont.init(descriptor: subtitleLabelFontDescriptor, size: titleLabelFontSize)
        }
        subtitleLabel.font = subtitleLabelFont
        subtitleLabel.textAlignment = .center
        return subtitleLabel
    } ()

    private lazy var titlesStackView: UIStackView = {
        let titlesStackView = UIStackView.init(arrangedSubviews: [titleLabel, subtitleLabel])
        titlesStackView.translatesAutoresizingMaskIntoConstraints = false
        titlesStackView.alignment = .center
        titlesStackView.axis = .vertical
        titlesStackView.distribution = .fillEqually
        return titlesStackView
    } ()

    private lazy var closeButton: UIButton = {
        let closeButton = UIButton.init(frame: .zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .wisteriaPurple
        let closeButtonImage = UIImage.init(systemName: "xmark")
        closeButton.setImage(closeButtonImage, for: .normal)
        closeButton.isHidden = true
        return closeButton
    } ()

    private lazy var pandaImageView: UIImageView = {
        let pandaImageView = UIImageView.init(frame: .zero)
        pandaImageView.translatesAutoresizingMaskIntoConstraints = false
        pandaImageView.layer.cornerRadius = pandaImageViewWidth / 2
        pandaImageView.layer.masksToBounds = true
        return pandaImageView
    } ()

    private lazy var mainActionLabel: UILabel = {
        let mainActionLabel = UILabel.init(frame: .zero)
        mainActionLabel.translatesAutoresizingMaskIntoConstraints = false
        mainActionLabel.textColor = .white
        var mainActionLabelFont = UIFont.systemFont(ofSize: mainActionLabelFontSize, weight: .semibold)
        if let mainActionLabelFontFontDescriptor = mainActionLabelFont.fontDescriptor.withDesign(.rounded) {
            mainActionLabelFont = UIFont.init(descriptor: mainActionLabelFontFontDescriptor, size: mainActionLabelFontSize)
        }
        subtitleLabel.font = mainActionLabelFont
        return mainActionLabel
    } ()

    private lazy var firstBulletPointView: BulletPointView = {
        let firstBulletPointView = BulletPointView.init(frame: .zero)
        firstBulletPointView.translatesAutoresizingMaskIntoConstraints = false
        firstBulletPointView.pointColor = .white
        firstBulletPointView.bulletColor = .white
        firstBulletPointView.pointLabel.font = UIFont.systemFont(ofSize: bulletPointViewFontSize, weight: .regular)
        return firstBulletPointView
    } ()

    private lazy var secondBulletPointView: BulletPointView = {
        let secondBulletPointView = BulletPointView.init(frame: .zero)
        secondBulletPointView.translatesAutoresizingMaskIntoConstraints = false
        secondBulletPointView.pointColor = .white
        secondBulletPointView.bulletColor = .white
        secondBulletPointView.pointLabel.font = UIFont.systemFont(ofSize: bulletPointViewFontSize, weight: .regular)
        return secondBulletPointView
    } ()

    private lazy var contentBackgroundView: UIView = {
        let contentBackgroundView = UIView.init(frame: .zero)
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentBackgroundView.backgroundColor = .wisteriaPurple
        return contentBackgroundView
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [pandaImageView, mainActionLabel, firstBulletPointView, secondBulletPointView])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.setCustomSpacing(pandaImageViewCustomSpacing, after: pandaImageView)
        return contentStackView
    } ()

    // MARK: - Init

    init(title: String, subtitle: String, imageName: String, mainActionString: String, firstSubActionString: String, secondSubActionString: String, width: CGFloat) {
        super.init(frame: .zero)

        backgroundColor = .white
        layer.cornerRadius = viewCornerRadius
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        subtitleLabel.text = subtitle
        pandaImageView.image = UIImage.init(named: imageName)
        mainActionLabel.text = mainActionString
        firstBulletPointView.pointText = firstSubActionString
        secondBulletPointView.pointText = secondSubActionString

        addSubview(closeButton)
        addSubview(titlesStackView)
        addSubview(contentBackgroundView)
        contentBackgroundView.addSubview(contentStackView)

        var height = titlesStackViewHeight
        height += contentStackViewTopBottomMargin * 2
        height += pandaImageViewHeight
        height += pandaImageViewCustomSpacing
        let contentStackViewWidth = width - 2 * Double(contentStackViewLeadingTrailingMargin)
        let size = CGSize.init(width: contentStackViewWidth, height: .greatestFiniteMagnitude)
        let mainActionLabelHeight = mainActionLabel.sizeThatFits(size).height
        let firstBulletPointViewHeight = firstBulletPointView.sizeThatFits(size).height
        let secondBulletPointViewHeight = secondBulletPointView.sizeThatFits(size).height
        height += mainActionLabelHeight
        height += firstBulletPointViewHeight
        height += secondBulletPointViewHeight
        bounds = CGRect.init(x: 0, y: 0, width: width, height: height)

        NSLayoutConstraint.activate([
            titlesStackView.topAnchor.constraint(equalTo: topAnchor),
            titlesStackView.heightAnchor.constraint(equalToConstant: titlesStackViewHeight),
            titlesStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titlesStackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            closeButton.widthAnchor.constraint(equalToConstant: closeButtonWidth),
            closeButton.heightAnchor.constraint(equalToConstant: closeButtonHeight),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: closeButtonTopMargin),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -closeButtonTrailingMargin),

            pandaImageView.widthAnchor.constraint(equalToConstant: pandaImageViewWidth),
            pandaImageView.heightAnchor.constraint(equalToConstant: pandaImageViewHeight),

            mainActionLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            mainActionLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            mainActionLabel.heightAnchor.constraint(equalToConstant: mainActionLabelHeight),

            firstBulletPointView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            firstBulletPointView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            firstBulletPointView.heightAnchor.constraint(equalToConstant: firstBulletPointViewHeight),

            secondBulletPointView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            secondBulletPointView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            secondBulletPointView.heightAnchor.constraint(equalToConstant: secondBulletPointViewHeight),

            contentBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentBackgroundView.topAnchor.constraint(equalTo: titlesStackView.bottomAnchor),
            contentBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentBackgroundView.topAnchor, constant: contentStackViewTopBottomMargin),
            contentStackView.bottomAnchor.constraint(equalTo: contentBackgroundView.bottomAnchor, constant: -contentStackViewTopBottomMargin),
            contentStackView.leadingAnchor.constraint(equalTo: contentBackgroundView.leadingAnchor, constant: contentStackViewLeadingTrailingMargin),
            contentStackView.trailingAnchor.constraint(equalTo: contentBackgroundView.trailingAnchor, constant: -contentStackViewLeadingTrailingMargin),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(title: String, subtitle: String, imageName: String)")
    }

    // MARK: - CoachMarkBodyView
    var nextControl: UIControl? {
        return closeButton
    }

    var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate?
}
