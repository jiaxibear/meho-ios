//
//  EarnBambooCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 5/6/22.
//  Copyright © 2022 Meho. All rights reserved.
//

import UIKit

class EarnBambooCollectionViewCell: UICollectionViewCell {

    private let bambooLabelFontSize = CGFloat(32)
    private let bambooLabelTrailingMargin = CGFloat(6)
    private let bambooNumberLabelFontSize = CGFloat(18)
    private let actionLabelFontSize = CGFloat(14)
    private let actionLabelLeadingTrailingMargin = CGFloat(16)
    private let contentViewCornerRadius = CGFloat(5)
    private let contentStackViewLeadingTrailingMargin = CGFloat(12)
    private let imageViewWidth = CGFloat(24)
    private let imageViewHeight = CGFloat(24)
    private let bambooNumberLabelWidth = CGFloat(44)
    private let bambooLabelWidth = CGFloat(24)
    private let subActionLabelFontSize = CGFloat(12)
    private let subActionTopMargin = CGFloat(10)
    private let dotViewTrailingMargin = CGFloat(6)
    private let dotViewHeight = CGFloat(10)

    private lazy var bambooLabel: UILabel = {
        let bambooLabel = UILabel.init(frame: .zero)
        bambooLabel.translatesAutoresizingMaskIntoConstraints = false
        bambooLabel.text = "🎋"
        bambooLabel.font = UIFont.systemFont(ofSize: bambooLabelFontSize)
        return bambooLabel
    } ()

    private lazy var bambooNumberLabel: UILabel = {
        let bambooNumberLabel = UILabel.init(frame: .zero)
        bambooNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        var bambooNumberLabelFont = UIFont.systemFont(ofSize: bambooNumberLabelFontSize, weight: .semibold)
        if let bambooNumberLabelFontDescriptor = bambooNumberLabelFont.fontDescriptor.withDesign(.rounded) {
            bambooNumberLabelFont = UIFont.init(descriptor: bambooNumberLabelFontDescriptor, size: bambooNumberLabelFontSize)
        }
        bambooNumberLabel.font = bambooNumberLabelFont
        bambooNumberLabel.textColor = .wisteriaPurple
        return bambooNumberLabel
    } ()

    private lazy var actionLabel: UILabel = {
        let actionLabel = UILabel.init(frame: .zero)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        var actionLabelFont = UIFont.systemFont(ofSize: actionLabelFontSize, weight: .semibold)
        if let actionLabelFontDescriptor = actionLabelFont.fontDescriptor.withDesign(.rounded) {
            actionLabelFont = UIFont.init(descriptor: actionLabelFontDescriptor, size: actionLabelFontSize)
        }
        actionLabel.font = actionLabelFont
        actionLabel.textColor = .slateGrey
        return actionLabel
    } ()

    private lazy var imageView: UIImageView = {
        let image = UIImage.init(named: "conversation_arrow_in_circle")
        let imageView = UIImageView.init(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [bambooLabel, bambooNumberLabel, actionLabel, imageView])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.distribution = .fill
        contentStackView.setCustomSpacing(bambooLabelTrailingMargin, after: bambooLabel)
        contentStackView.setCustomSpacing(actionLabelLeadingTrailingMargin, after: bambooNumberLabel)
        contentStackView.setCustomSpacing(actionLabelLeadingTrailingMargin, after: actionLabel)
        return contentStackView
    } ()

    private lazy var subActionsWrapperView: UIView = {
        let subActionsView = UIView.init(frame: .zero)
        subActionsView.translatesAutoresizingMaskIntoConstraints = false
        return subActionsView
    } ()

    private lazy var allContentStackView: UIStackView = {
        let allContentStackView = UIStackView.init(arrangedSubviews: [contentStackView, subActionsWrapperView])
        allContentStackView.translatesAutoresizingMaskIntoConstraints = false
        allContentStackView.axis = .vertical
        allContentStackView.alignment = .fill
        allContentStackView.distribution = .fill
        return allContentStackView
    } ()

    private var subActionViews: [UIView] = []

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
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.addSubview(allContentStackView)
        contentView.backgroundColor = .paleGray

        NSLayoutConstraint.activate([
            allContentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentStackViewLeadingTrailingMargin),
            allContentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentStackViewLeadingTrailingMargin),
            allContentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            allContentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            contentStackView.heightAnchor.constraint(equalToConstant: 50),

            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),

            bambooNumberLabel.widthAnchor.constraint(equalToConstant: bambooNumberLabelWidth),

            bambooLabel.widthAnchor.constraint(equalToConstant: bambooLabelWidth),
        ])
    }

    // MARK: - Internal
    func setEarnBamboo(_ earnBamboo: EarnBamboo) {
        bambooNumberLabel.text = earnBamboo.numberOfBamboo
        actionLabel.text = earnBamboo.action
        for subActionView in subActionViews {
            subActionView.removeFromSuperview()
        }

        if earnBamboo.subActions.count > 0 {
            for subAction in earnBamboo.subActions {
                let dotView = dotLabel()
                subActionViews.append(dotView)
                subActionsWrapperView.addSubview(dotView)
                let subActionLabel = subActionLabel(subAction: subAction)
                subActionViews.append(subActionLabel)
                subActionsWrapperView.addSubview(subActionLabel)
            }

            for i in subActionViews.indices {
                let subActionView = subActionViews[i]
                if i % 2 == 1 {
                    subActionView.topAnchor.constraint(equalTo: subActionViews[i - 1].topAnchor).isActive = true
                    subActionView.leadingAnchor.constraint(equalTo: subActionViews[i - 1].trailingAnchor, constant: dotViewTrailingMargin).isActive = true
                    subActionView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
                } else {
                    subActionView.leadingAnchor.constraint(equalTo: bambooNumberLabel.leadingAnchor).isActive = true
                    subActionView.heightAnchor.constraint(equalToConstant: dotViewHeight).isActive = true
                    if i != 0 {
                        subActionView.topAnchor.constraint(equalTo: subActionViews[i - 1].bottomAnchor, constant: subActionTopMargin).isActive = true
                    }
                }
            }
            subActionsWrapperView.isHidden = false
            contentView.setNeedsUpdateConstraints()
        } else {
            subActionsWrapperView.isHidden = true
        }
    }

    func subActionLabel(subAction: String) -> UILabel {
        let subActionLabel = UILabel.init(frame: .zero)
        subActionLabel.translatesAutoresizingMaskIntoConstraints = false
        subActionLabel.textColor = .textCharcoalGrey
        var subActionLabelFont = UIFont.systemFont(ofSize: subActionLabelFontSize, weight: .regular)
        if let subActionLabelFontDescriptor = subActionLabelFont.fontDescriptor.withDesign(.rounded) {
            subActionLabelFont = UIFont.init(descriptor: subActionLabelFontDescriptor, size: subActionLabelFontSize)
        }
        subActionLabel.font = subActionLabelFont
        subActionLabel.text = subAction
        subActionLabel.numberOfLines = 0
        return subActionLabel
    }

    func dotLabel() -> UILabel {
        let dotLabel = UILabel.init(frame: .zero)
        dotLabel.translatesAutoresizingMaskIntoConstraints = false
        dotLabel.textColor = .wisteriaPurple
        dotLabel.text = "•"
        return dotLabel
    }
}
