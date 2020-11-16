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
    private static let featureSloganFontSize = CGFloat(18)
    private static let seeCategoryTosloganMargin = CGFloat(46)
    private static let seeCategoryFontSize = CGFloat(16)


    private lazy var sloganLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .white
        let pinyinfontDescriptor = UIFont.systemFont(ofSize: ListedFeaturedCategoryCollectionViewCell.featureSloganFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: pinyinfontDescriptor!, size: 0)
        label.numberOfLines = 0
        return label
    } ()

    private lazy var seeCategoryLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .white
        let pinyinfontDescriptor = UIFont.systemFont(ofSize: ListedFeaturedCategoryCollectionViewCell.seeCategoryFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: pinyinfontDescriptor!, size: 0)
        label.numberOfLines = 0
        return label
    } ()

    private lazy var featuredImageView: WebImageView = {
        let imageView = WebImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.delegate = self
        return imageView
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

        // Sets up title label.
        contentView.addSubview(featuredImageView)
        contentView.addSubview(sloganLabel)
        contentView.addSubview(seeCategoryLabel)

        // Sets up constraints
        sloganLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ListedFeaturedCategoryCollectionViewCell.horizontalMargin).isActive = true
        sloganLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ListedFeaturedCategoryCollectionViewCell.horizontalMargin).isActive = true
        sloganLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ListedFeaturedCategoryCollectionViewCell.sloganTopMargin).isActive = true

        seeCategoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ListedFeaturedCategoryCollectionViewCell.horizontalMargin).isActive = true
        seeCategoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ListedFeaturedCategoryCollectionViewCell.horizontalMargin).isActive = true
        seeCategoryLabel.topAnchor.constraint(equalTo: sloganLabel.bottomAnchor, constant: ListedFeaturedCategoryCollectionViewCell.seeCategoryTosloganMargin).isActive = true

        featuredImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        featuredImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        featuredImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        featuredImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    }

    // MARK - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
    }

    // MARK: - set data
    func setCategory(category:Category) {
        let seeCategoryText = "See " + category.title

        let attributedContent = NSMutableAttributedString(string: seeCategoryText.trimmingCharacters(in: .whitespacesAndNewlines), attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue])
        seeCategoryLabel.attributedText = attributedContent
//        seeCategoryLabel.text = seeCategoryText

        if let featuredSlogan = category.featuredSlogan {
            sloganLabel.text = featuredSlogan
        }

        if let imageKey = category.featuredImageKey {
            let s3Key = S3ImageViewKey.init(bucket: "mehoassets213338-mehoadmin", key: imageKey)
            featuredImageView.imageKey = s3Key
        }
    }
}
