//
//  QuestionCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 8/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let contentViewCornerRadius = CGFloat(6)
    private let contentViewBorderWidth = CGFloat(2)
    private let stackViewLeadingTrailingMargin = CGFloat(12)
    private let subtitleLabelFontSize = CGFloat(12)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel.init(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = .darkGrayTwo
        let subtitleLabelFontDescriptor = UIFont.systemFont(ofSize: subtitleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        subtitleLabel.font = UIFont.init(descriptor: subtitleLabelFontDescriptor!, size: subtitleLabelFontSize)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        return subtitleLabel
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    } ()

    private var stackViewHeightConstraint: NSLayoutConstraint!

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
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.layer.borderWidth = contentViewBorderWidth
        contentView.clipsToBounds = true
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: stackViewLeadingTrailingMargin).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -stackViewLeadingTrailingMargin).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stackViewHeightConstraint = stackView.heightAnchor.constraint(equalToConstant: 0)
    }

    // MARK: - Internal
    func setQuestion(_ question: ProfileQuestion) {
        titleLabel.text = question.title
        subtitleLabel.text = question.subtitle
        contentView.layer.borderColor = question.color.cgColor
        if question.isSelected {
            contentView.backgroundColor = question.color
            titleLabel.textColor = .white
            subtitleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .white
            titleLabel.textColor = .darkGrayTwo
            subtitleLabel.textColor = .darkGrayTwo
        }
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: question.titleFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor!, size: question.titleFontSize)
        let labelMaxWidth = contentView.bounds.width - 2 * stackViewLeadingTrailingMargin
        let labelMaxHeight = contentView.bounds.height
        let labelFittingSize = CGSize.init(width: labelMaxWidth, height: labelMaxHeight)
        var height = titleLabel.sizeThatFits(labelFittingSize).height
        if subtitleLabel.text != nil {
            height = height + subtitleLabel.sizeThatFits(labelFittingSize).height
        }
        stackViewHeightConstraint.constant = max(height, labelMaxHeight)
    }
}
