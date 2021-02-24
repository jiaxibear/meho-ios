//
//  DialogStreamEmptyCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 2/23/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

class DialogStreamEmptyCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let imageViewWidth = CGFloat(220)
    private let imageViewHeight = CGFloat(220)
    private let imageViewTopMargin = CGFloat(80)
    private let titleLabelFontSize = CGFloat(30)
    private let subtitleLabelFontSize = CGFloat(20)
    private let titleLabelTopMargin = CGFloat(24)
    private let subtitleLabelTopMargin = CGFloat(40)
    private let labelWidth = CGFloat(250)

    // MARK: - Properties
    private lazy var imageView: UIImageView = {
        let image = UIImage.init(named: "empty_state_no_content")
        let imageView = UIImageView.init(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("NoContentTitle", comment: "")
        titleLabel.textColor = .darkGrayTwo
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        let titleLabelFont = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium)
        if let titleLabelFontDescriptor = titleLabelFont.fontDescriptor.withDesign(.rounded) {
            titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        } else {
            titleLabel.font = titleLabelFont
        }
        return titleLabel
    } ()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel.init(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = NSLocalizedString("NoContentSubtitle", comment: "")
        subtitleLabel.textColor = .slateGrey
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        let subtitleLabelFont = UIFont.systemFont(ofSize: subtitleLabelFontSize, weight: .light)
        if let subtitleLabelFontDescriptor = subtitleLabelFont.fontDescriptor.withDesign(.rounded) {
            subtitleLabel.font = UIFont.init(descriptor: subtitleLabelFontDescriptor, size: subtitleLabelFontSize)
        } else {
            subtitleLabel.font = subtitleLabelFont
        }
        subtitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return subtitleLabel
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.alignment = .center
        contentStackView.axis = .vertical
        contentStackView.setCustomSpacing(titleLabelTopMargin, after: imageView)
        contentStackView.setCustomSpacing(subtitleLabelTopMargin, after: titleLabel)
        return contentStackView
    } ()

    private static var sizingCell = DialogStreamEmptyCollectionViewCell.init(frame: .zero);

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: imageViewTopMargin),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.widthAnchor.constraint(equalToConstant: labelWidth),
            subtitleLabel.widthAnchor.constraint(equalToConstant: labelWidth)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect)")
    }

    // MARK: - Internal
    class func cellHeight() -> CGFloat {
        return sizingCell.contentStackViewHeight() + sizingCell.imageViewTopMargin
    }

    // MARK: - Private
    private func contentStackViewHeight() -> CGFloat {
        var height = imageViewHeight + subtitleLabelTopMargin + titleLabelTopMargin
        let labelFittingSize = CGSize.init(width: labelWidth, height: .greatestFiniteMagnitude)
        height = height + titleLabel.sizeThatFits(labelFittingSize).height + subtitleLabel.sizeThatFits(labelFittingSize).height
        return height
    }
}
