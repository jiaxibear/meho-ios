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
    private let bambooLabelTrailingMargin = CGFloat(12)
    private let bambooNumberLabelFontSize = CGFloat(18)
    private let actionLabelFontSize = CGFloat(14)
    private let actionLabelLeadingTrailingMargin = CGFloat(24)
    private let contentViewCornerRadius = CGFloat(5)
    private let contentStackViewLeadingTrailingMargin = CGFloat(12)
    private let imageViewWidth = CGFloat(24)
    private let imageViewHeight = CGFloat(24)
    private let bambooNumberLabelWidth = CGFloat(44)

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
        contentView.addSubview(contentStackView)
        contentView.backgroundColor = .paleGray

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentStackViewLeadingTrailingMargin),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentStackViewLeadingTrailingMargin),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),

            bambooNumberLabel.widthAnchor.constraint(equalToConstant: bambooNumberLabelWidth),
        ])
    }
}
