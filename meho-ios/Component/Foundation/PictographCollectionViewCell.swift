//
//  PictographCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PictographCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let descriptionTopMargin = CGFloat(13)
    private let cardCornerRadius = CGFloat(10)

    // MARK: - Properties
    private let contentEnLabel = UILabel.init(frame: .zero)

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
        contentView.backgroundColor = .wisteriaPurple
        contentView.layer.cornerRadius = cardCornerRadius
        // Sets up elements in the cell
        setupContentEnLabelUI()
    }

    private func setupContentEnLabelUI() {
        contentEnLabel.numberOfLines = 1
        contentEnLabel.translatesAutoresizingMaskIntoConstraints = false
        contentEnLabel.textColor = .white
        contentEnLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(30))
        contentView.addSubview(contentEnLabel)

        // constraints
        contentEnLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        contentEnLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.bounds.height * 0.25).isActive = true
    }

    // MARK: - Public
    public func setPictographCardData(pictograph: Pictograph) {
        contentEnLabel.text = pictograph.content_en
        contentEnLabel.textColor = .white
        contentEnLabel.sizeToFit()

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Add stuff for rending that need view to be already setup
    }
}
