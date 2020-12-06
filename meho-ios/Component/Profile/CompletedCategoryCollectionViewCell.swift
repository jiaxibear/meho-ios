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
    private let titleLabelCornerRadius = CGFloat(8)
    private let titleLabelBorderWidth = CGFloat(1)
    private let titleLabelFontSize = CGFloat(12)
    private let subTypeTitleLabelFontSize = CGFloat(8)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = titleLabelNumberOfLines
        titleLabel.clipsToBounds = true
        titleLabel.layer.cornerRadius = titleLabelCornerRadius
        titleLabel.layer.borderWidth = titleLabelBorderWidth
        titleLabel.textAlignment = .center
        return titleLabel
    } ()

    var contentCategory: ProfileContentCategory! {
        didSet {
            titleLabel.text = contentCategory.title
            if contentCategory.isSubType {
                if let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
                    titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: subTypeTitleLabelFontSize)
                }
                titleLabel.layer.borderColor = UIColor.skyBlue.cgColor
            } else {
                if let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
                    titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
                }
                titleLabel.layer.borderColor = UIColor.wisteriaPurple.cgColor
            }
            if contentCategory.isSelected {
                if contentCategory.isSubType {
                    titleLabel.backgroundColor = .skyBlue
                } else {
                    titleLabel.backgroundColor = .wisteriaPurple
                }
                titleLabel.textColor = .white
            } else {
                titleLabel.backgroundColor = .white
                if contentCategory.isSubType {
                    titleLabel.textColor = .skyBlue
                } else {
                    titleLabel.textColor = .wisteriaPurple
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
        contentView.addSubview(titleLabel)

        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
