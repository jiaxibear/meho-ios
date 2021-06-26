//
//  InterestQuestionCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 6/13/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

class InterestQuestionCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let contentViewCornerRadius = CGFloat(8)
    private let contentViewBorderWidth = CGFloat(2)
    private let contentViewUnselectedBorderWidth = CGFloat(1)
    private let stackViewLeadingTrailingMargin = CGFloat(10)
    private let unselectedOpacity = CGFloat(0.1)
    private let imageViewWidth = CGFloat(130)
    private let imageViewHeight = CGFloat(120)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [imageView, titleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    } ()

    private var stackViewHeightConstraint: NSLayoutConstraint!

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
        layer.cornerRadius = contentViewCornerRadius
        layer.applySketchShadow(color: .slateGrey, alpha: Float(unselectedOpacity), x: 0, y: 2, blur: 4, spread: 1)
        contentView.addSubview(stackView)
        backgroundColor = .white
        imageView.widthAnchor.constraint(equalToConstant: imageViewWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: stackViewLeadingTrailingMargin).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -stackViewLeadingTrailingMargin).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stackViewHeightConstraint = stackView.heightAnchor.constraint(equalToConstant: 0)
    }

    // MARK: - Internal
    func setQuestion(_ question: ProfileQuestion) {
        titleLabel.text = question.title
        if question.isSelected {
            titleLabel.textColor = .darkGrayTwo
            layer.borderColor = UIColor.darkGrayTwo.cgColor
            layer.borderWidth = contentViewBorderWidth
            layer.shadowOpacity = 0
        } else {
            titleLabel.textColor = .textBlueGray
            layer.borderColor = UIColor.textBlueGray.withAlphaComponent(unselectedOpacity).cgColor
            layer.borderWidth = contentViewUnselectedBorderWidth
            layer.shadowOpacity = Float(unselectedOpacity)
        }
        if let imageName = question.imageName {
            imageView.image = UIImage.init(named: imageName)
        }
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: question.titleFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor!, size: question.titleFontSize)
        let labelMaxWidth = contentView.bounds.width - 2 * stackViewLeadingTrailingMargin
        let labelMaxHeight = contentView.bounds.height
        let labelFittingSize = CGSize.init(width: labelMaxWidth, height: labelMaxHeight)
        let height = titleLabel.sizeThatFits(labelFittingSize).height + imageViewHeight
        stackViewHeightConstraint.constant = max(height, labelMaxHeight)
    }
}
