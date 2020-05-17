//
//  SurvivalPhraseCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 5/9/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class SurvivalPhraseCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let contentViewCornerRadius = CGFloat(2)
    private let contentViewBackgroundColorAlpha = CGFloat(0.8)
    private let backgroundImageViewAlpha = CGFloat(0.8)

    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView.init(frame: .zero)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.isHidden = true
        backgroundImageView.alpha = backgroundImageViewAlpha
        backgroundImageView.contentMode = .scaleAspectFill
        return backgroundImageView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.clipsToBounds = true
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(titleLabel)

        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }

    // MARK: - Internal
    func setSurvivalPhraseCategory(_ survivalPhrase: SurvivalPhraseCategory) {
        titleLabel.text = survivalPhrase.title
        let titleLabelFontSize = survivalPhrase.titleFontSize
        let titlefontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: titlefontDescriptor!, size: 0)
        if let backgroundColor = survivalPhrase.backgroundColor {
            contentView.backgroundColor = backgroundColor.withAlphaComponent(contentViewBackgroundColorAlpha)
            backgroundImageView.isHidden = true
        } else if let backgroundImage = survivalPhrase.backgroundImage {
            contentView.backgroundColor = .clear
            backgroundImageView.isHidden = false
            backgroundImageView.image = backgroundImage
        }
    }
}
