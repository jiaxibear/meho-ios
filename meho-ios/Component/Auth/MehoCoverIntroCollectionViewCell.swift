//
//  SignInStoriesCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 5/2/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

struct CoverIntro {
    let title: String
    let subtitle: String
    let backgroundColor: UIColor
}

class MehoCoverIntroCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(30)
    private let titleLabelTopMargin = CGFloat(40)
    private let subtitleLabelFontSize = CGFloat(18)
    private let subtitleLabelTopMargin = CGFloat(40)
    private let labelsLeadingTrailingMargin = CGFloat(14)
    private let contentViewCornerRadius = CGFloat(8)

    // MARK: - Properties
    private lazy var titleLabel:UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .white
        label.textAlignment = .center
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: fontDescriptor!, size: titleLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    } ()

    private lazy var subtitleLabel:UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .white
        label.textAlignment = .center
        let fontDescriptor = UIFont.systemFont(ofSize: subtitleLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        label.font = UIFont.init(descriptor: fontDescriptor!, size: subtitleLabelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
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
        setupTitleLabel()
        setupSubtitleLabel()
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.clipsToBounds = true
    }

    // MARK: - Elements layout, style & constrains
    private func setupTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: titleLabelTopMargin).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: labelsLeadingTrailingMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -labelsLeadingTrailingMargin).isActive = true
    }

    private func setupSubtitleLabel() {
        contentView.addSubview(subtitleLabel)
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: subtitleLabelTopMargin).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: labelsLeadingTrailingMargin).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -labelsLeadingTrailingMargin).isActive = true
    }

    // MARK: - Public
    public func setCoverIntro(_ coverIntro: CoverIntro) {
        contentView.backgroundColor = coverIntro.backgroundColor
        titleLabel.text = coverIntro.title
        subtitleLabel.text = coverIntro.subtitle
    }
}
