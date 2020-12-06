//
//  CompletedExpressionCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 11/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AVFoundation

class CompletedExpressionCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let categoryLabelCornerRadius = CGFloat(2)
    private let categoryLabelWidth = CGFloat(60)
    private let categoryLabelHeight = CGFloat(20)
    private let categoryLabelFontSize = CGFloat(10)
    private let titleLabelFontSize = CGFloat(20)
    private let pinyinLabelFontSize = CGFloat(16)
    private let titleEnLabelFontSize = CGFloat(16)
    private let categoryLabelSpacing = CGFloat(12)
    private let labelSpacing = CGFloat(8)
    private let contentLeadingTrailingMargin = CGFloat(20)
    private let contentTopMargin = CGFloat(20)
    private let contentBottomMargin = CGFloat(18)
    private let listenButtonWidth = CGFloat(30)
    private let listenButtonHeight = CGFloat(30)
    private let listenButtonTrailingMargin = CGFloat(4)
    private let contentViewCornerRadius = CGFloat(8)
    private let contentViewShadowRadius = CGFloat(3)
    private let contentViewShadowSpread = CGFloat(2)

    // MARK: - Properties
    private lazy var categoryLabel: UILabel = {
        let categoryLabel = UILabel.init(frame: .zero)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.clipsToBounds = true
        categoryLabel.layer.cornerRadius = categoryLabelCornerRadius
        categoryLabel.textColor = .white
        categoryLabel.backgroundColor = .wisteriaPurple
        categoryLabel.textAlignment = .center
        if let categoryLabelFontDescriptor = UIFont.systemFont(ofSize: categoryLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            categoryLabel.font = UIFont.init(descriptor: categoryLabelFontDescriptor, size: categoryLabelFontSize)
        }
        return categoryLabel
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .wisteriaPurple
        titleLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: titleLabelFontSize)
        return titleLabel
    } ()

    private lazy var pinyinLabel: UILabel = {
        let pinyinLabel = UILabel.init(frame: .zero)
        pinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        pinyinLabel.textColor = .mehoDarkGray
        if let pinyinLabelFontDescriptor = UIFont.systemFont(ofSize: pinyinLabelFontSize).fontDescriptor.withDesign(.rounded) {
            pinyinLabel.font = UIFont.init(descriptor: pinyinLabelFontDescriptor, size: pinyinLabelFontSize)
        }
        return pinyinLabel
    } ()

    private lazy var titleEnLabel: UILabel = {
        let titleEnLabel = UILabel.init(frame: .zero)
        titleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        titleEnLabel.textColor = .darkGrayTwo
        if let titleEnLabelFontDescriptor = UIFont.systemFont(ofSize: titleEnLabelFontSize).fontDescriptor.withDesign(.rounded) {
            titleEnLabel.font = UIFont.init(descriptor: titleEnLabelFontDescriptor, size: titleEnLabelFontSize)
        }
        return titleEnLabel
    } ()

    private lazy var labelsStackView: UIStackView = {
        let labelsStackView = UIStackView.init(arrangedSubviews: [titleLabel, pinyinLabel, titleEnLabel])
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .leading
        labelsStackView.distribution = .equalSpacing
        return labelsStackView
    } ()

    private lazy var listenButton: UIButton = {
        let listenButton = UIButton.init(frame: .zero)
        listenButton.translatesAutoresizingMaskIntoConstraints = false
        let listenButtonImage = UIImage.init(named: "stories_speaker")
        listenButton.setImage(listenButtonImage, for: .normal)
        return listenButton
    } ()

    private var player: AVPlayer?

    var expression: Expression! {
        didSet {
            titleLabel.text = expression.contentZh
            pinyinLabel.text = expression.contentPinyin
            titleEnLabel.text = expression.contentEn
            categoryLabel.text = expression.category.rawValue
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
        layer.shadowColor = UIColor.paleLilac.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
        layer.shadowRadius = contentViewShadowRadius
        layer.shadowOpacity = 1.0
        layer.backgroundColor = UIColor.clear.cgColor

        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.paleLilac.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.backgroundColor = .white
        contentView.addSubview(labelsStackView)
        contentView.addSubview(listenButton)
        contentView.addSubview(categoryLabel)

        categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentTopMargin).isActive = true
        categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        categoryLabel.widthAnchor.constraint(equalToConstant: categoryLabelWidth).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: categoryLabelHeight).isActive = true

        labelsStackView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: categoryLabelSpacing).isActive = true
        labelsStackView.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor).isActive = true
        labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentBottomMargin).isActive = true

        listenButton.widthAnchor.constraint(equalToConstant: listenButtonWidth).isActive = true
        listenButton.heightAnchor.constraint(equalToConstant: listenButtonHeight).isActive = true
        listenButton.topAnchor.constraint(equalTo: labelsStackView.topAnchor).isActive = true
        listenButton.trailingAnchor.constraint(equalTo: labelsStackView.trailingAnchor, constant: -listenButtonTrailingMargin).isActive = true
    }
}
