//
//  ExpressionCollectionReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 12/12/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

protocol ExpressionCollectionReusableViewDelegate: AnyObject {
    func didTapSeeAllButton()
}

class ExpressionCollectionReusableView: UICollectionReusableView {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(20)
    private let contentLeadingTrailingMargin = CGFloat(16)
    private let seeAllButtonFontSize = CGFloat(12)
    private let seeAllButtonCornerRadius = CGFloat(10)
    private let seeAllButtonBorderWidth = CGFloat(1)
    private let seeAllButtonWidth = CGFloat(66)

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var isSeeAllButtonHidden = true {
        didSet {
            seeAllButton.isHidden = isSeeAllButtonHidden
        }
    }

    var delegate: ExpressionCollectionReusableViewDelegate?

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        var titleLabelFont = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium)
        if let titleLabelFontDescriptor = titleLabelFont.fontDescriptor.withDesign(.rounded) {
            titleLabelFont = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        }
        titleLabel.font = titleLabelFont
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private lazy var seeAllButton: UIButton = {
        let seeAllButton = UIButton.init(frame: .zero)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.setTitleColor(.textBlueGray, for: .normal)
        if let seeAllButtonFontDescriptor = UIFont.systemFont(ofSize: seeAllButtonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded) {
            seeAllButton.titleLabel?.font = UIFont.init(descriptor: seeAllButtonFontDescriptor, size: seeAllButtonFontSize)
        }
        seeAllButton.setTitle(NSLocalizedString("SeeAllWithoutNumberText", comment: ""), for: .normal)
        seeAllButton.addTarget(self, action: #selector(didTapSeeAllButton), for: .touchUpInside)
        seeAllButton.layer.borderColor = UIColor.textBlueGray.cgColor
        seeAllButton.layer.cornerRadius = seeAllButtonCornerRadius
        seeAllButton.layer.borderWidth = seeAllButtonBorderWidth
        seeAllButton.isHidden = true
        return seeAllButton
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
        addSubview(titleLabel)
        addSubview(seeAllButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentLeadingTrailingMargin),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentLeadingTrailingMargin),
            seeAllButton.widthAnchor.constraint(equalToConstant: seeAllButtonWidth),
        ])
    }

    // MARK: - Private
    @objc
    private func didTapSeeAllButton() {
        delegate?.didTapSeeAllButton()
    }
}

