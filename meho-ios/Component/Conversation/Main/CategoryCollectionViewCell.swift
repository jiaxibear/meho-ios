//
//  CategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 2/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import Foundation

class CategoryCollectionViewCell: UICollectionViewCell, WebImageViewDelegate {

    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(12)

    private let coverImageViewVerticalMargin = CGFloat(10)
    private let coverImageViewHeight = CGFloat(40)
    private let titleToImageMargin = CGFloat(10)
    private let titleBottomMargin = CGFloat(6)
    private let contentViewCornerRadius = CGFloat(10)
    private let contentViewShadowRadius = CGFloat(3)
    private let contentViewShadowSpread = CGFloat(3)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .mehoDarkGray
        var font =  UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium)
        if let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded) {
            font = UIFont.init(descriptor: fontDescriptor, size: titleLabelFontSize)
        }
        titleLabel.font = font
        return titleLabel
    } ()

    private lazy var coverImageView: WebImageView = {
        let coverImageView = WebImageView.init(frame: .zero)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFit
        coverImageView.delegate = self
        return coverImageView
    } ()

    private var shadowLayer:CAShapeLayer?

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowColor = UIColor.paleLilac.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.masksToBounds = false
        layer.shadowRadius = contentViewShadowRadius
        let shadowBounds = bounds.insetBy(dx: -contentViewShadowSpread, dy: -contentViewShadowSpread)
        layer.shadowPath = UIBezierPath(roundedRect: shadowBounds, cornerRadius: contentViewCornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.backgroundColor = .white

        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)

        // Sets up constraints
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: coverImageViewVerticalMargin),
            coverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight),
            coverImageView.widthAnchor.constraint(equalToConstant: coverImageViewHeight),

            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: titleToImageMargin),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -titleBottomMargin)
        ])
        self.contentView.isHidden = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
        contentView.isHidden = false
        layer.shadowOpacity = 1
    }

    // MARK: - Public
    public func setCategory(category: Category) {
        // Sets the text for the title label.
        titleLabel.text = category.title
        
        // Downloads the image.
        if let coverImageURL = category.coverImageURL {
            coverImageView.imageURL = coverImageURL
        } else if let imageKey = category.coverImageKey {
            let s3Key = S3ResourceKey.init(bucket: "mehoassets213338-mehoadmin", key: imageKey)
            coverImageView.imageKey = s3Key
        } else {
            coverImageView.image = UIImage.init(named: "tag_see_all")
        }
    }
}
