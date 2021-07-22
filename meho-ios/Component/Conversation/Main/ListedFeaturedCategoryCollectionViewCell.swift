//
//  ListedFeaturedCategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 11/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ListedFeaturedCategoryCollectionViewCell: UICollectionViewCell, WebImageViewDelegate {

    // MARK: - Constants
    private static let horizontalMargin = CGFloat(22)
    private static let sloganTopMargin = CGFloat(24)
    private static let featureSloganFontSize = CGFloat(15)
    private static let seeCategoryTosloganMargin = CGFloat(46)
    private static let learnMoreButtonFontSize = CGFloat(10)
    private static let learnMoreButtonCornerRadius = CGFloat(6)
    private static let cornerRadius = CGFloat(8)
    private let labelAndButtonStackViewMargin = CGFloat(18)
    private let learnMoreButtonWidth = CGFloat(88)
    private let learnMoreButtonHeight = CGFloat(22)

    private lazy var sloganLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .white
        let pinyinfontDescriptor = UIFont.systemFont(ofSize: ListedFeaturedCategoryCollectionViewCell.featureSloganFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: pinyinfontDescriptor!, size: 0)
        label.numberOfLines = 0
        return label
    } ()

    private lazy var learnMoreButton: UIButton = {
        let learnMoreButton = UIButton.init(frame: .zero)
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = false
        learnMoreButton.setTitleColor(.darkGrayTwo, for: .normal)
        var learnMoreButtonFont = UIFont.systemFont(ofSize: ListedFeaturedCategoryCollectionViewCell.learnMoreButtonFontSize, weight: .regular)
        if let learnMoreButtonFontDescriptor = learnMoreButtonFont.fontDescriptor.withDesign(.rounded) {
            learnMoreButtonFont = UIFont.init(descriptor: learnMoreButtonFontDescriptor, size: ListedFeaturedCategoryCollectionViewCell.learnMoreButtonFontSize)
        }
        learnMoreButton.titleLabel?.font = learnMoreButtonFont
        learnMoreButton.setTitle(NSLocalizedString("LearnMoreButtonTitle", comment: ""), for: .normal)
        learnMoreButton.backgroundColor = .white
        learnMoreButton.layer.cornerRadius = ListedFeaturedCategoryCollectionViewCell.learnMoreButtonCornerRadius
        learnMoreButton.layer.masksToBounds = true
        learnMoreButton.isUserInteractionEnabled = false
        return learnMoreButton
    } ()

    private lazy var featuredImageView: WebImageView = {
        let imageView = WebImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.delegate = self
        return imageView
    } ()

    private lazy var purpleBackgroundView: UIView = {
        let purpleBackgroundView = UIView.init(frame: .zero)
        purpleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        purpleBackgroundView.backgroundColor = .periwinkleBlueTwo.withAlphaComponent(0.6)
        purpleBackgroundView.layer.masksToBounds = true
        purpleBackgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        purpleBackgroundView.layer.cornerRadius = ListedFeaturedCategoryCollectionViewCell.cornerRadius
        return purpleBackgroundView
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [featuredImageView, purpleBackgroundView])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .horizontal
        contentStackView.alignment = .fill
        contentStackView.distribution = .fillEqually
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
        backgroundColor = .white

        layer.cornerRadius = ListedFeaturedCategoryCollectionViewCell.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.palePurple.cgColor
        layer.applySketchShadow(color: .paleLilac, alpha: 1, x: 0, y: 2, blur: 4, spread: 0.5)

        purpleBackgroundView.addSubview(sloganLabel)
        purpleBackgroundView.addSubview(learnMoreButton)
        contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            sloganLabel.leadingAnchor.constraint(equalTo: purpleBackgroundView.leadingAnchor, constant: labelAndButtonStackViewMargin),
            sloganLabel.trailingAnchor.constraint(equalTo: purpleBackgroundView.trailingAnchor, constant: -labelAndButtonStackViewMargin),
            sloganLabel.topAnchor.constraint(equalTo: purpleBackgroundView.topAnchor, constant: labelAndButtonStackViewMargin),

            learnMoreButton.widthAnchor.constraint(equalToConstant: learnMoreButtonWidth),
            learnMoreButton.heightAnchor.constraint(equalToConstant: learnMoreButtonHeight),
            learnMoreButton.leadingAnchor.constraint(equalTo: sloganLabel.leadingAnchor),
            learnMoreButton.bottomAnchor.constraint(equalTo: purpleBackgroundView.bottomAnchor, constant: -labelAndButtonStackViewMargin)
        ])
    }

    // MARK - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
    }

    // MARK: - set data
    func setCategory(category:Category) {
        if let featuredSlogan = category.featuredSlogan {
            sloganLabel.text = featuredSlogan
        }

        if let imageKey = category.featuredImageKey {
            let s3Key = S3ResourceKey.init(bucket: "mehoassets213338-mehoadmin", key: imageKey)
            featuredImageView.imageKey = s3Key
        }
    }
}
