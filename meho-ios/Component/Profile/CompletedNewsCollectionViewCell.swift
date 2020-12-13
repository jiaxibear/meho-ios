//
//  CompletedNewsCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 11/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class CompletedNewsCollectionViewCell: UICollectionViewCell {

    private let imageViewCornerRadius = CGFloat(8)
    private let titleLabelFontSize = CGFloat(18)
    private let subtitleLabelFontSize = CGFloat(14)
    private let labelsStackViewSpacing = CGFloat(12)
    private let labelsStackViewImageViewMargin = CGFloat(40)
    private let titleLabelNumberOfLines = 3
    private let subtitleLabelNumberOfLines = 2
    private let imageViewWidth = CGFloat(120)
    private let imageViewHeight = CGFloat(120)

    private lazy var imageView: WebImageView = {
        let imageView = WebImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageViewCornerRadius
        imageView.contentMode = .scaleAspectFill
        return imageView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        if titleLabelFontDescriptor != nil {
            titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor!, size: titleLabelFontSize)
        }
        titleLabel.numberOfLines = titleLabelNumberOfLines
        return titleLabel
    } ()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel.init(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = .textBlueGray
        let subtitleLabelFontDescriptor = UIFont.systemFont(ofSize: subtitleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        if subtitleLabelFontDescriptor != nil {
            subtitleLabel.font = UIFont.init(descriptor: subtitleLabelFontDescriptor!, size: subtitleLabelFontSize)
        }
        subtitleLabel.numberOfLines = subtitleLabelNumberOfLines
        return subtitleLabel
    } ()

    private lazy var labelsStackView: UIStackView = {
        let labelsStackView = UIStackView.init(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.spacing = labelsStackViewSpacing
        return labelsStackView
    } ()

    var news: News! {
        didSet {
            titleLabel.text = news.title_en
            subtitleLabel.text = news.reason
            imageView.imageKey = news.imageKey
        }
    }

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
        contentView.addSubview(labelsStackView)
        contentView.addSubview(imageView)

        labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        labelsStackView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -labelsStackViewImageViewMargin).isActive = true

        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
        let imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: imageViewHeight)
        imageViewHeightConstraint.priority = .defaultHigh
        imageViewHeightConstraint.isActive = true
    }
}
