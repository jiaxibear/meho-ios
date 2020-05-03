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
    private let titleLabelFontSize = CGFloat(16)
    private let coverImageViewHeight = CGFloat(92)
    private let titleLabelVerticalMargin = CGFloat(12)
    private let titleLabelLeadingMargin = CGFloat(11)
    private let contentViewCornerRadius = CGFloat(10)
    private let contentViewShadowRadius = CGFloat(3)
    private let contentViewShadowSpread = CGFloat(3)

    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let coverImageView = WebImageView.init(frame: .zero)
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

        // Sets up cover image view.
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.delegate = self
        contentView.addSubview(coverImageView)

        // Sets up title label.
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .mehoDarkGray
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        contentView.addSubview(titleLabel)

        // Sets up constraints
        coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: titleLabelLeadingMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: titleLabelVerticalMargin).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -titleLabelVerticalMargin).isActive = true
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
        titleLabel.sizeToFit()
        
        // Downloads the image.
        if let coverImageURL = category.coverImageURL {
            coverImageView.imageURL = coverImageURL
        }
    }
}
