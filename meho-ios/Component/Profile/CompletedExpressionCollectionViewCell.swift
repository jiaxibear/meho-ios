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
    private let difficultyLabelCornerRadius = CGFloat(2)
    private let difficultyLabelWidth = CGFloat(60)
    private let difficultyLabelHeight = CGFloat(20)
    private let difficultyLabelFontSize = CGFloat(10)
    private let titleLabelFontSize = CGFloat(20)
    private let pinyinLabelFontSize = CGFloat(16)
    private let titleEnLabelFontSize = CGFloat(16)
    private let difficultyLabelSpacing = CGFloat(12)
    private let labelSpacing = CGFloat(8)
    private let contentLeadingTrailingMargin = CGFloat(20)
    private let contentTopMargin = CGFloat(20)
    private let contentBottomMargin = CGFloat(18)
    private let listenButtonWidth = CGFloat(30)
    private let listenButtonHeight = CGFloat(30)
    private let listenButtonTrailingMargin = CGFloat(24)

    // MARK: - Properties
    private lazy var difficultyLabel: UILabel = {
        let difficultyLabel = UILabel.init(frame: .zero)
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.clipsToBounds = true
        difficultyLabel.layer.cornerRadius = difficultyLabelCornerRadius
        difficultyLabel.textColor = .white
        difficultyLabel.backgroundColor = .wisteriaPurple
        if let difficultyLabelFontDescriptor = UIFont.systemFont(ofSize: difficultyLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            difficultyLabel.font = UIFont.init(descriptor: difficultyLabelFontDescriptor, size: difficultyLabelFontSize)
        }
        return difficultyLabel
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
        let labelsStackView = UIStackView.init(arrangedSubviews: [difficultyLabel, titleLabel, pinyinLabel, titleEnLabel])
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.setCustomSpacing(difficultyLabelSpacing, after: difficultyLabel)
        labelsStackView.spacing = labelSpacing
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

    var expression: Chapter? {
        didSet {
            if expression != nil {
               
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
        contentView.addSubview(labelsStackView)

        labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentTopMargin).isActive = true
        labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentBottomMargin).isActive = true

        difficultyLabel.widthAnchor.constraint(equalToConstant: difficultyLabelWidth).isActive = true
        difficultyLabel.heightAnchor.constraint(equalToConstant: difficultyLabelHeight).isActive = true

        listenButton.widthAnchor.constraint(equalToConstant: listenButtonWidth).isActive = true
        listenButton.heightAnchor.constraint(equalToConstant: listenButtonHeight).isActive = true
        listenButton.topAnchor.constraint(equalTo: labelsStackView.topAnchor).isActive = true
        listenButton.trailingAnchor.constraint(equalTo: labelsStackView.trailingAnchor, constant: -listenButtonTrailingMargin).isActive = true
    }
}
