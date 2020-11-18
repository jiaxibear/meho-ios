//
//  ProfileHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 10/4/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Constants
    private let topLineViewHeight = CGFloat(1)
    private let titleLabelFontSize = CGFloat(18)
    private let labelsStackViewTopBottomMargin = CGFloat(14)
    private let labelsStackViewSpecialBottomMargin = CGFloat(10)
    private let subtitleLabelFontSize = CGFloat(12)
    private let labelsStackViewSpacing = CGFloat(4)
    private let labelLeadingTrailingMargin = CGFloat(18)
    private let seeAllButtonFontSize = CGFloat(12)

    // MARK: - Models
    var profileHeader: ProfileHeader! {
        didSet {
            titleLabel.text = profileHeader.title
            let count = profileHeader.count
            if count == 0 {
                seeAllButton.isHidden = true
                if let subtitle = profileHeader.subtitle {
                    subtitleLabel.isHidden = false
                    subtitleLabel.text = subtitle
                } else {
                    subtitleLabel.isHidden = true
                }
            } else {
                let seeAllButtonTitleFormat = NSLocalizedString("SeeAllText", comment: "")
                seeAllButton.setTitle(String.init(format: seeAllButtonTitleFormat, String(count)), for: .normal)
                seeAllButton.isHidden = false
                subtitleLabel.isHidden = true
            }
            setNeedsUpdateConstraints()
        }
    }

    // MARK: - UI
    private lazy var topLineView: UIView = {
        let topLineView = UIView.init(frame: .zero)
        topLineView.translatesAutoresizingMaskIntoConstraints = false
        topLineView.backgroundColor = .lightBlueGreyTwo
        return topLineView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        titleLabel.numberOfLines = 0
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)!
        titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        return titleLabel
    } ()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel.init(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = .textBlueGray
        subtitleLabel.numberOfLines = 0
        if let subtitleLabelFontDescriptor = UIFont.systemFont(ofSize: subtitleLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded) {
            subtitleLabel.font = UIFont.init(descriptor: subtitleLabelFontDescriptor, size: subtitleLabelFontSize)
        }
        return subtitleLabel
    } ()

    private lazy var labelsStackView: UIStackView = {
        let labelsStackView = UIStackView.init(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.spacing = labelsStackViewSpacing
        return labelsStackView
    } ()

    private lazy var seeAllButton: UIButton = {
        let seeAllButton = UIButton.init(frame: .zero)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.setTitleColor(.wisteriaPurple, for: .normal)
        seeAllButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        if let seeAllButtonFontDescriptor = UIFont.systemFont(ofSize: seeAllButtonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded) {
            seeAllButton.titleLabel?.font = UIFont.init(descriptor: seeAllButtonFontDescriptor, size: seeAllButtonFontSize)
        }
        return seeAllButton
    } ()

    private lazy var labelsStackViewBottomConstraint: NSLayoutConstraint = {
        return labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    } ()

    private lazy var labelsStackViewTrailingToViewConstraint: NSLayoutConstraint = {
        return labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -labelLeadingTrailingMargin)
    } ()

    private lazy var labelsStackViewTrailingToSeeAllButtonConstraint: NSLayoutConstraint = {
        return labelsStackView.trailingAnchor.constraint(equalTo: seeAllButton.leadingAnchor, constant: -labelLeadingTrailingMargin)
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
        addSubview(topLineView)
        addSubview(labelsStackView)
        addSubview(seeAllButton)

        topLineView.heightAnchor.constraint(equalToConstant: topLineViewHeight).isActive = true
        topLineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topLineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true

        labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: labelLeadingTrailingMargin).isActive = true
        labelsStackViewBottomConstraint.isActive = true
        labelsStackView.topAnchor.constraint(equalTo: topAnchor, constant: labelsStackViewTopBottomMargin).isActive = true

        seeAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -labelLeadingTrailingMargin).isActive = true
    }

    // MARK: - UICollectionViewCell
    override func updateConstraints() {
        super.updateConstraints()
        if subtitleLabel.isHidden {
            labelsStackViewBottomConstraint.constant = -labelsStackViewTopBottomMargin
        } else {
            labelsStackViewBottomConstraint.constant = -labelsStackViewSpecialBottomMargin
        }
        if seeAllButton.isHidden {
            labelsStackViewTrailingToViewConstraint.isActive = true
            labelsStackViewTrailingToSeeAllButtonConstraint.isActive = false
        } else {
            labelsStackViewTrailingToViewConstraint.isActive = false
            labelsStackViewTrailingToSeeAllButtonConstraint.isActive = true
        }
    }
}
