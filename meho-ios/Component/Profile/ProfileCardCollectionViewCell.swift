//
//  ProfileCardCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 10/4/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ProfileCardCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(10)
    private let subtitleLabelFontSize = CGFloat(10)
    private let imageViewHeight = CGFloat(100)
    private let contentTypeLabelCornerRadius = CGFloat(2)
    private let contentTypeLabelWidth = CGFloat(50)
    private let contentTypeLabelHeight = CGFloat(16)
    private let contentTypeLabelFontSize = CGFloat(8)
    private let contentStackViewSpacing = CGFloat(8)

    // MARK: - Model
    var profileCard: ProfileCard! {
        didSet {
            titleLabel.text = profileCard.title
            subtitleLabel.text = profileCard.subtitle
            imageView.imageKey = profileCard.imageKey
            switch profileCard.profileCardType {
            case .expression:
                contentTypeLabel.text = "Expression"
                contentTypeLabel.backgroundColor = .periwinkleBlue
                break
            case .story:
                contentTypeLabel.text = "Story"
                contentTypeLabel.backgroundColor = .skyBlue
                break
            case .talk:
                contentTypeLabel.text = "Talk"
                contentTypeLabel.backgroundColor = .wisteriaPurple
                break
            }
            setNeedsUpdateConstraints()
        }
    }

    // MARK: - UI
    private lazy var imageView: WebImageView = {
        let imageView = WebImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()

    private lazy var contentTypeLabel: UILabel = {
        let contentTypeLabel = UILabel.init(frame: .zero)
        contentTypeLabel.textColor = .white
        contentTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentTypeLabel.clipsToBounds = true
        contentTypeLabel.layer.cornerRadius = contentTypeLabelCornerRadius
        let contentTypeLabelFontDescriptor = UIFont.systemFont(ofSize: contentTypeLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)!
        contentTypeLabel.font = UIFont.init(descriptor: contentTypeLabelFontDescriptor, size: contentTypeLabelFontSize)
        contentTypeLabel.textAlignment = .center
        return contentTypeLabel
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)!
        titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel.init(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = .darkGrayTwo
        subtitleLabel.font = UIFont.init(name: "PingFangSC-Regular", size: subtitleLabelFontSize)
        subtitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        subtitleLabel.numberOfLines = 0
        return subtitleLabel
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [imageView, contentTypeLabel, titleLabel, subtitleLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .leading
        contentStackView.spacing = contentStackViewSpacing
        return contentStackView
    } ()

    private lazy var contentStackViewHeightConstraint: NSLayoutConstraint = {
        return contentStackView.heightAnchor.constraint(equalToConstant: 0)
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
        contentView.addSubview(contentStackView)

        contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        imageView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageViewHeight).isActive = true

        contentTypeLabel.widthAnchor.constraint(equalToConstant: contentTypeLabelWidth).isActive = true
        contentTypeLabel.heightAnchor.constraint(equalToConstant: contentTypeLabelHeight).isActive = true
    }

    // MARK: - UIView
    override func updateConstraints() {
        super.updateConstraints()
        var height = imageViewHeight + contentTypeLabelHeight + contentStackViewSpacing * 3
        let labelFittingSize = CGSize.init(width: bounds.width, height: .greatestFiniteMagnitude)
        height += titleLabel.sizeThatFits(labelFittingSize).height
        height += subtitleLabel.sizeThatFits(labelFittingSize).height
        contentStackViewHeightConstraint.constant = height
        contentStackViewHeightConstraint.isActive = true
    }
}
