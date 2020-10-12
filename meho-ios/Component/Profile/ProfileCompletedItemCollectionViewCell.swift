//
//  ProfileCompletedItemCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 10/3/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ProfileCompletedItemCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let contentHeight = CGFloat(90)
    private let contentWidth = CGFloat(90)
    private let titleLabelFontSize = CGFloat(14)
    private let countLabelFontSize = CGFloat(20)

    // MARK: - Model
    var completedItem: ProfileCompletedItem! {
        didSet {
            titleLabel.text = completedItem.title
            countLabel.text = String(completedItem.count)
            contentBackgroundView.backgroundColor = completedItem.color
            setNeedsUpdateConstraints()
        }
    }

    // MARK: - UI
    private lazy var contentBackgroundView: UIView = {
        let contentBackgroundView = UIView.init(frame: .zero)
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentBackgroundView.clipsToBounds = true
        contentBackgroundView.layer.cornerRadius = contentWidth / 2
        return contentBackgroundView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .textCharcoalGrey
        titleLabel.textAlignment = .center
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)!
        titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        return titleLabel
    } ()

    private lazy var countLabel: UILabel = {
        let countLabel = UILabel.init(frame: .zero)
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.textColor = .textCharcoalGrey
        let countLabelFontDescriptor = UIFont.systemFont(ofSize: countLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)!
        countLabel.font = UIFont.init(descriptor: countLabelFontDescriptor, size: countLabelFontSize)
        return countLabel
    } ()

    private lazy var labelsStackView: UIStackView = {
        let labelsStackView = UIStackView.init(arrangedSubviews: [countLabel, titleLabel])
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        return labelsStackView
    } ()

    private lazy var labelsStackViewHeightConstraint: NSLayoutConstraint = {
        return labelsStackView.heightAnchor.constraint(equalToConstant: 0)
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
        contentView.addSubview(contentBackgroundView)
        contentBackgroundView.addSubview(labelsStackView)

        contentBackgroundView.widthAnchor.constraint(equalToConstant: contentWidth).isActive = true
        contentBackgroundView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
        contentBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        contentBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        labelsStackView.centerYAnchor.constraint(equalTo: contentBackgroundView.centerYAnchor).isActive = true
        labelsStackView.centerXAnchor.constraint(equalTo: contentBackgroundView.centerXAnchor).isActive = true
        labelsStackView.widthAnchor.constraint(equalTo: contentBackgroundView.widthAnchor).isActive = true
    }

    // MARK: - UIView
    override func updateConstraints() {
        super.updateConstraints()
        let labelFittingSize = CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)
        let titleLabelHeight = titleLabel.sizeThatFits(labelFittingSize).height
        let countLabelHeight = countLabel.sizeThatFits(labelFittingSize).height
        labelsStackViewHeightConstraint.constant = titleLabelHeight + countLabelHeight
        labelsStackViewHeightConstraint.isActive = true
    }
}
