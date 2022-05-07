//
//  ProfilePandaHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 5/6/22.
//  Copyright © 2022 Meho. All rights reserved.
//

import UIKit

class ProfilePandaHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(18)
    private let visitPandaButtonFontSize = CGFloat(16)
    private let contentLeadingTrailingMargin = CGFloat(16)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("PandaText", comment: "")
        titleLabel.textColor = .darkGrayTwo
        var titleFont = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .regular)
        if let titleFontDescriptor = titleFont.fontDescriptor.withDesign(.rounded) {
            titleFont = UIFont.init(descriptor: titleFontDescriptor, size: titleLabelFontSize)
        }
        titleLabel.font = titleFont
        return titleLabel
    } ()

    private lazy var visitPandaButton: UIButton = {
        let visitPandaButton = UIButton.init(frame: .zero)
        visitPandaButton.translatesAutoresizingMaskIntoConstraints = false
        visitPandaButton.setTitleColor(.wisteriaPurple, for: .normal)
        visitPandaButton.setTitle(NSLocalizedString("VisitButtonTitle", comment: ""), for: .normal)
        var visitPandaButtonFont = UIFont.systemFont(ofSize: visitPandaButtonFontSize, weight: .medium)
        if let visitPandaButtonFontDescriptor = visitPandaButtonFont.fontDescriptor.withDesign(.rounded) {
            visitPandaButtonFont = UIFont.init(descriptor: visitPandaButtonFontDescriptor, size: visitPandaButtonFontSize)
        }
        visitPandaButton.titleLabel?.font = visitPandaButtonFont
        return visitPandaButton
    } ()

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(visitPandaButton)
        backgroundColor = UIColor.skyBlue.withAlphaComponent(0.1)

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentLeadingTrailingMargin),
            visitPandaButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            visitPandaButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentLeadingTrailingMargin)
        ])
    }
}
