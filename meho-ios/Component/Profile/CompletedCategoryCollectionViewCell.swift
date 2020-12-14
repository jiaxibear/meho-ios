//
//  CompletedCategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 11/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class CompletedCategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let titleLabelNumberOfLines = 1
    private let contentViewCornerRadius = CGFloat(8)
    private let contentViewBorderWidth = CGFloat(1)
    private let titleLabelFontSize = CGFloat(12)
    private let titleLabelLeadingTrailingMargin = CGFloat(12)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = titleLabelNumberOfLines
        if let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        }
        return titleLabel
    } ()

    var contentCategory: ProfileContentCategory! {
        didSet {
            titleLabel.text = contentCategory.title
            if contentCategory.isSubType {
                contentView.layer.borderColor = UIColor.greenBlue.cgColor
            } else {
                contentView.layer.borderColor = UIColor.skyBlue.cgColor
            }
            if contentCategory.isSelected {
                if contentCategory.isSubType {
                    contentView.backgroundColor = .greenBlue
                } else {
                    contentView.backgroundColor = .skyBlue
                }
                titleLabel.textColor = .white
            } else {
                contentView.backgroundColor = .white
                if contentCategory.isSubType {
                    titleLabel.textColor = .greenBlue
                } else {
                    titleLabel.textColor = .skyBlue
                }
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
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.layer.borderWidth = contentViewBorderWidth
        contentView.addSubview(titleLabel)

        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: titleLabelLeadingTrailingMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -titleLabelLeadingTrailingMargin).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
