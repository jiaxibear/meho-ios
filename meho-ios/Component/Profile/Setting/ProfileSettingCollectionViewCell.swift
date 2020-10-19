//
//  ProfileSettingCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 9/12/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ProfileSettingCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private let customSpacing = CGFloat(10)
    private let subtitleLabelFontSize = CGFloat(12)
    private let titleLabelOnlyFontSize = CGFloat(12)
    private let titleLabelFontSize = CGFloat(14)
    private let oneLineTopBottomMargin = CGFloat(10)
    private let twoLineTopBottomMargin = CGFloat(16)
    private let contentStackViewLeadingTrailingMargin = CGFloat(22)
    private let bottomLineHeight = CGFloat(1)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return titleLabel
    } ()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel.init(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textColor = .textBlueGray
        let subtitleLabelFontDescriptor = UIFont.systemFont(ofSize: subtitleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)!
        subtitleLabel.font = UIFont.init(descriptor: subtitleLabelFontDescriptor, size: subtitleLabelFontSize)
        return subtitleLabel
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [titleLabel, subtitleLabel])
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.spacing = customSpacing
        return contentStackView
    } ()

    private lazy var bottomLineView: UIView = {
        let bottomLineView = UIView.init(frame: .zero)
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomLineView.backgroundColor = .lightBlueGrey
        return bottomLineView
    } ()

    private lazy var contentStackViewTopConstraint: NSLayoutConstraint = {
        return contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor)
    } ()

    private lazy var contentStackViewBottomConstraint: NSLayoutConstraint = {
        return contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    } ()

    private static var sizingView = ProfileSettingCollectionViewCell.init(frame: .zero)

    var profileSetting: ProfileSetting {
        didSet {
            titleLabel.text = profileSetting.title
            if let subtitle = profileSetting.subtitle {
                subtitleLabel.text = subtitle
                //subtitleLabel.isHidden = false
            } else {
                //subtitleLabel.isHidden = true
            }
            switch profileSetting.style {
            case .appVersion:
                let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelOnlyFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)!
                titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelOnlyFontSize)
                titleLabel.textColor = .slateGrey
                contentView.backgroundColor = .paleGray
                break
            case .header:
                let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelOnlyFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)!
                titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelOnlyFontSize)
                titleLabel.textColor = .darkGrayTwo
                contentView.backgroundColor = .paleGray
                break
            case .item:
                let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)!
                titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
                titleLabel.textColor = .darkGrayTwo
                contentView.backgroundColor = .white
            }
            setNeedsLayout()
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
        self.profileSetting = ProfileSetting.init(title: "", subtitle: nil, type: .account, style: .header)
        super.init(frame: frame)
        contentView.addSubview(contentStackView)
        contentView.addSubview(bottomLineView)
        contentStackViewTopConstraint.isActive = true
        contentStackViewBottomConstraint.isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentStackViewLeadingTrailingMargin).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentStackViewLeadingTrailingMargin).isActive = true
        bottomLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        bottomLineView.heightAnchor.constraint(equalToConstant: bottomLineHeight).isActive = true
        bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel.isHidden = true
    }

    override func updateConstraints() {
        super.updateConstraints()
        if profileSetting.subtitle != nil {
            contentStackViewTopConstraint.constant = twoLineTopBottomMargin
            contentStackViewBottomConstraint.constant = -twoLineTopBottomMargin
        } else {
            contentStackViewTopConstraint.constant = oneLineTopBottomMargin
            contentStackViewBottomConstraint.constant = -oneLineTopBottomMargin
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if profileSetting.subtitle != nil {
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }

    // MARK: - Internal
    class func cellHeight(width: CGFloat, profileSetting: ProfileSetting) -> CGFloat {
        sizingView.profileSetting = profileSetting
        let labelWidth = width - 2 * sizingView.contentStackViewLeadingTrailingMargin
        let labelFittingSize = CGSize.init(width: labelWidth, height: .greatestFiniteMagnitude)
        var height = sizingView.titleLabel.sizeThatFits(labelFittingSize).height + sizingView.bottomLineHeight
        if profileSetting.subtitle != nil {
            height = height + 2 * sizingView.twoLineTopBottomMargin
            height = height + sizingView.customSpacing + sizingView.subtitleLabel.sizeThatFits(labelFittingSize).height
        } else {
            height = height + 2 * sizingView.oneLineTopBottomMargin
        }
        return height
    }
}
