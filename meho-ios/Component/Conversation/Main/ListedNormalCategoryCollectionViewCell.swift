//
//  ListedNormalCategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 11/15/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ListedNormalCategoryCollectionViewCell: UICollectionViewCell, WebImageViewDelegate {

    // MARK: - Constants
    private static let horizontalMargin = CGFloat(22)
    private static let labelFontSize = CGFloat(20)
    private static let labelTextHeight = CGFloat(24)
    private static let categoryIconHeight = CGFloat(35)
    private static let lineDelimiterHeight = CGFloat(1)

    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .darkGray
        let pinyinfontDescriptor = UIFont.systemFont(ofSize: ListedNormalCategoryCollectionViewCell.labelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: pinyinfontDescriptor!, size: 0)
        label.numberOfLines = 1
        return label
    } ()

    private lazy var categoryImageView: WebImageView = {
        let imageView = WebImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.delegate = self
        return imageView
    } ()

    private let lineDelimiterView: UIView = {
        let lineView = UIView.init(frame: .zero)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .textBlueGray
        return lineView
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineDelimiterView)
        contentView.addSubview(categoryImageView)

        // Sets up constraints
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ListedNormalCategoryCollectionViewCell.horizontalMargin).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: ListedNormalCategoryCollectionViewCell.labelTextHeight).isActive = true

        categoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ListedNormalCategoryCollectionViewCell.horizontalMargin).isActive = true
        categoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        categoryImageView.heightAnchor.constraint(equalToConstant: ListedNormalCategoryCollectionViewCell.categoryIconHeight).isActive = true
        categoryImageView.widthAnchor.constraint(equalToConstant: ListedNormalCategoryCollectionViewCell.categoryIconHeight).isActive = true

        lineDelimiterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lineDelimiterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        lineDelimiterView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        lineDelimiterView.heightAnchor.constraint(equalToConstant: ListedNormalCategoryCollectionViewCell.lineDelimiterHeight).isActive = true
    }

    // MARK - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
    }

    // MARK: - set data
    func setCategory(category:Category) {
        titleLabel.text = category.title

        if let imageKey = category.coverImageKey {
            let s3Key = S3ResourceKey.init(bucket: "mehoassets213338-mehoadmin", key: imageKey)
            categoryImageView.imageKey = s3Key
        }
    }
}
