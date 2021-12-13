//
//  MustKnowPhraseCategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 12/7/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

class MustKnowPhraseCategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let contentViewCornerRadius = CGFloat(8)
    private let titleFontSize = CGFloat(16)
    private let practiceLabelFontSize = CGFloat(10)
    private let imageViewWidth = CGFloat(60)
    private let imageViewHeight = CGFloat(60)
    private let titleLabelLeadingMargin = CGFloat(20)
    private let practiceProgressViewTopMargin = CGFloat(14)
    private let practiceProgressViewWidth = CGFloat(120)
    private let practiceLabelLeadingMargin = CGFloat(10)

    // MARK: - Properties
    private lazy var imageView: WebImageView = {
        let imageView = WebImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        var titleLabelFont = UIFont.systemFont(ofSize: titleFontSize, weight: .medium)
        if let titleLabelFontDescriptor = titleLabelFont.fontDescriptor.withDesign(.rounded) {
            titleLabelFont = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleFontSize)
        }
        titleLabel.font = titleLabelFont
        titleLabel.textColor = .darkGrayTwo
        return titleLabel
    } ()

    private lazy var practiceProgressView: UIProgressView = {
        let practiceProgressView = UIProgressView.init(progressViewStyle: .default)
        practiceProgressView.translatesAutoresizingMaskIntoConstraints = false
        practiceProgressView.progressTintColor = .wisteriaPurple
        practiceProgressView.trackTintColor = .paleGray
        return practiceProgressView
    } ()

    private lazy var practiceLabel: UILabel = {
        let practiceLabel = UILabel.init(frame: .zero)
        practiceLabel.translatesAutoresizingMaskIntoConstraints = false
        var practiceLabelFont = UIFont.systemFont(ofSize: practiceLabelFontSize, weight: .medium)
        if let practiceLabelFontDescriptor = practiceLabelFont.fontDescriptor.withDesign(.rounded) {
            practiceLabelFont = UIFont.init(descriptor: practiceLabelFontDescriptor, size: practiceLabelFontSize)
        }
        practiceLabel.font = practiceLabelFont
        practiceLabel.textColor = .textCharcoalGrey
        return practiceLabel
    } ()

    var mustKnowPhraseCategory: MustKnowPhraseCategory? {
        didSet {
            if let mustKnowPhraseCategory = mustKnowPhraseCategory {
                titleLabel.text = mustKnowPhraseCategory.title
                if let imageURLString = mustKnowPhraseCategory.imageURLString {
                    imageView.imageURL = URL.init(string: imageURLString)
                }
                let practiced = mustKnowPhraseCategory.practiced
                let total = mustKnowPhraseCategory.total
                if total != 0 {
                    practiceProgressView.progress = Float(practiced) / Float(total)
                }
                let mustKnowPhraseProgressTextFormat = NSLocalizedString("MustKnowPhraseProgressText", comment: "")
                practiceLabel.text = String.init(format: mustKnowPhraseProgressTextFormat, String(practiced), String(total))
            }
        }
    }

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowColor = UIColor.paleLilac.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.backgroundColor = UIColor.clear.cgColor

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.backgroundColor = .white

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(practiceProgressView)
        contentView.addSubview(practiceLabel)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: titleLabelLeadingMargin),

            practiceProgressView.widthAnchor.constraint(equalToConstant: practiceProgressViewWidth),
            practiceProgressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: practiceProgressViewTopMargin),
            practiceProgressView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            practiceLabel.centerYAnchor.constraint(equalTo: practiceProgressView.centerYAnchor),
            practiceLabel.leadingAnchor.constraint(equalTo: practiceProgressView.trailingAnchor, constant: practiceLabelLeadingMargin)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    override func prepareForReuse() {
        titleLabel.text = nil
        imageView.image = nil
        practiceProgressView.progress = 0
        practiceLabel.text = nil
    }
}
