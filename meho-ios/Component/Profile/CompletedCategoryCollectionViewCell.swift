//
//  CompletedCategoryCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 11/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class CompletedCategoryCollectionViewCell: UICollectionViewCell {

    private let titleLabelNumberOfLines = 1
    private let titleLabelCornerRadius = CGFloat(8)
    private let titleLabelBorderWidth = CGFloat(1)

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = titleLabelNumberOfLines
        titleLabel.clipsToBounds = true
        titleLabel.layer.cornerRadius = titleLabelCornerRadius
        titleLabel.layer.borderWidth = titleLabelBorderWidth
        return titleLabel
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
        contentView.addSubview(titleLabel)

        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    override var isSelected: Bool {
        didSet {
            
        }
    }
}
