//
//  ProfessionQuestionCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 6/13/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

class ProfessionQuestionCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let contentViewCornerRadius = CGFloat(8)
    private let contentViewBorderWidth = CGFloat(2)
    private let contentViewUnselectedBorderWidth = CGFloat(1)
    private let stackViewLeadingTrailingMargin = CGFloat(16)
    private let unselectedOpacity = CGFloat(0.1)
    private let imageViewWidth = CGFloat(100)
    private let imageViewHeight = CGFloat(80)
    private let stackViewSpacing = CGFloat(14)
    private let titleFontSize = CGFloat(16)
    private let subtitleFontSize = CGFloat(12)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [ titleLabel, imageView ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = stackViewSpacing
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
        layer.cornerRadius = contentViewCornerRadius
        layer.applySketchShadow(color: .slateGrey, alpha: Float(unselectedOpacity), x: 0, y: 2, blur: 4, spread: 1)
        contentView.addSubview(stackView)
        backgroundColor = .white

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: stackViewLeadingTrailingMargin),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -stackViewLeadingTrailingMargin),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }

    // MARK: - Internal
    func setQuestion(_ question: ProfileQuestion) {
        if let subtitle = question.subtitle {
            let title = question.title
            let profession = String.init(format: "%@%@", title, subtitle)
            let attributedProfession = NSMutableAttributedString.init(string: profession)
            let titleRange = attributedProfession.mutableString.range(of: title)
            var titleFont = UIFont.systemFont(ofSize: titleFontSize, weight: .medium)
            if let titleFontDescriptor = titleFont.fontDescriptor.withDesign(.rounded) {
                titleFont = UIFont.init(descriptor: titleFontDescriptor, size: titleFontSize)
            }
            let titleAttributes:[NSAttributedString.Key : Any] = [
                .font : titleFont,
                .foregroundColor : UIColor.slateGrey
            ]
            attributedProfession.addAttributes(titleAttributes, range: titleRange)
            let subtitleRange = attributedProfession.mutableString.range(of: subtitle)
            var subtitleFont = UIFont.systemFont(ofSize: subtitleFontSize, weight: .light)
            if let subtitleFontDescriptor = subtitleFont.fontDescriptor.withDesign(.rounded) {
                subtitleFont = UIFont.init(descriptor: subtitleFontDescriptor, size: subtitleFontSize)
            }
            let subtitleAttributes:[NSAttributedString.Key : Any] = [
                .font : subtitleFont,
                .foregroundColor : UIColor.slateGrey
            ]
            attributedProfession.addAttributes(subtitleAttributes, range: subtitleRange)
            titleLabel.attributedText = attributedProfession
        } else {
            titleLabel.text = question.title
        }

        if question.isSelected {
            layer.borderColor = UIColor.darkGrayTwo.cgColor
            layer.borderWidth = contentViewBorderWidth
            layer.shadowOpacity = 0
        } else {
            layer.borderColor = UIColor.textBlueGray.withAlphaComponent(unselectedOpacity).cgColor
            layer.borderWidth = contentViewUnselectedBorderWidth
            layer.shadowOpacity = Float(unselectedOpacity)
        }
        if let imageName = question.imageName {
            imageView.isHidden = false
            imageView.image = UIImage.init(named: imageName)
        } else {
            imageView.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.redrawShadowPath(bounds: bounds)
    }
}
