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
    private static let horizontalMargin = CGFloat(14)
    private static let labelFontSize = CGFloat(12)
    private static let labelTextHeight = CGFloat(24)
    private static let categoryIconHeight = CGFloat(38)
    private static let lineDelimiterHeight = CGFloat(1)
    private static let cornerRadius = CGFloat(8)

    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .mehoDarkGray
        let pinyinfontDescriptor = UIFont.systemFont(ofSize: ListedNormalCategoryCollectionViewCell.labelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: pinyinfontDescriptor!, size: 0)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    } ()

    private lazy var categoryImageView: WebImageView = {
        let imageView = WebImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.delegate = self
        return imageView
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [categoryImageView, titleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
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

        layer.applySketchShadow(color: .paleLilac, alpha: 1, x: 0, y: 0, blur: 6, spread: 0.5)
        layer.cornerRadius = ListedNormalCategoryCollectionViewCell.cornerRadius
        contentView.addSubview(stackView)

        // Sets up constraints
        NSLayoutConstraint.activate([
            categoryImageView.heightAnchor.constraint(equalToConstant: ListedNormalCategoryCollectionViewCell.categoryIconHeight),
            categoryImageView.widthAnchor.constraint(equalToConstant: ListedNormalCategoryCollectionViewCell.categoryIconHeight),

            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ListedNormalCategoryCollectionViewCell.horizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ListedNormalCategoryCollectionViewCell.horizontalMargin),
            stackView.heightAnchor.constraint(equalToConstant: ListedNormalCategoryCollectionViewCell.categoryIconHeight),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
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
