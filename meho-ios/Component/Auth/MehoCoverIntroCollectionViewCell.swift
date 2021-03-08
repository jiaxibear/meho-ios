//
//  SignInStoriesCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 5/2/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

struct CoverIntro {
    let title: String
    let image: UIImage?
}

class MehoCoverIntroCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(22)
    private static let imageViewHeightWidthRatio = CGFloat(5) / CGFloat(6)
    private static let reservedTitleLabelHeight = CGFloat(90)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .darkGrayTwo
        label.textAlignment = .center
        let labelFont = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium)
        if let fontDescriptor = labelFont.fontDescriptor.withDesign(.rounded) {
            label.font = UIFont.init(descriptor: fontDescriptor, size: titleLabelFontSize)
        } else {
            label.font = labelFont
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    } ()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()

    var coverIntro: CoverIntro? {
        didSet {
            if let coverIntro = coverIntro {
                titleLabel.text = coverIntro.title
                imageView.image = coverIntro.image
            }
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

        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),

            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: MehoCoverIntroCollectionViewCell.imageViewHeightWidthRatio)
        ])
    }

    // MARK: - Internal
    class func cellHeight(width: CGFloat) -> CGFloat {
        return width * imageViewHeightWidthRatio + reservedTitleLabelHeight
    }
}
