//
//  DuoOtherRoleCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class DuoOtherRoleCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private static let roleImageViewSize = CGFloat(30)
    private static let leadingMargin = CGFloat(16)
    private static let trailingMargin = CGFloat(56)
    private static let roleLabelFontSize = CGFloat(14)
    private static let roleImageViewAndroleLabelMargin = CGFloat(10)
    private static let contentBackgroundViewBackgroundColorAlpha = CGFloat(0.1)
    private static let contentBackgroundViewCornerRadius = CGFloat(10)
    private static let contentBackgroundViewAndRoleImageViewMargin = CGFloat(6)
    private static let contentFontSize = CGFloat(18)
    private static let contentLabelMargin = CGFloat(18)

    // MARK: - Properties
    // MARK: UI
    private lazy var roleImageView: UIImageView = {
        let avatarImageView = UIImageView.init(frame: .zero)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = DuoOtherRoleCollectionViewCell.roleImageViewSize / 2
        return avatarImageView
    } ()

    private lazy var roleLabel: UILabel = {
        let roleLabel = UILabel.init(frame: .zero)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.textColor = .textBlueGray
        let roleLabelFontDescriptor = UIFont.systemFont(ofSize: DuoOtherRoleCollectionViewCell.roleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        roleLabel.font = UIFont.init(descriptor: roleLabelFontDescriptor!, size: DuoOtherRoleCollectionViewCell.roleLabelFontSize)
        return roleLabel
    } ()

    private lazy var contentBackgroundView: UIView = {
        let contentBackgroundView = UIView.init(frame: .zero)
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentBackgroundView.clipsToBounds = true
        contentBackgroundView.layer.cornerRadius = DuoOtherRoleCollectionViewCell.contentBackgroundViewCornerRadius
        contentBackgroundView.backgroundColor = UIColor.skyBlue.withAlphaComponent(DuoOtherRoleCollectionViewCell.contentBackgroundViewBackgroundColorAlpha)
        return contentBackgroundView
    } ()

    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel.init(frame: .zero)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .mehoDarkGray
        contentLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: DuoOtherRoleCollectionViewCell.contentFontSize)
        return contentLabel
    } ()

    private static var sizingCell = DuoOtherRoleCollectionViewCell.init(frame: .zero);

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(roleImageView)
        addSubview(roleLabel)
        addSubview(contentBackgroundView)
        contentBackgroundView.addSubview(contentLabel)

        roleImageView.widthAnchor.constraint(equalToConstant: DuoOtherRoleCollectionViewCell.roleImageViewSize).isActive = true
        roleImageView.heightAnchor.constraint(equalToConstant: DuoOtherRoleCollectionViewCell.roleImageViewSize).isActive = true
        roleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DuoOtherRoleCollectionViewCell.leadingMargin).isActive = true
        roleImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        roleLabel.leadingAnchor.constraint(equalTo: roleImageView.trailingAnchor, constant: DuoOtherRoleCollectionViewCell.roleImageViewAndroleLabelMargin).isActive = true
        roleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DuoOtherRoleCollectionViewCell.trailingMargin).isActive = true
        roleLabel.centerYAnchor.constraint(equalTo: roleImageView.centerYAnchor).isActive = true

        contentBackgroundView.leadingAnchor.constraint(equalTo: roleLabel.leadingAnchor).isActive = true
        contentBackgroundView.trailingAnchor.constraint(equalTo: roleLabel.trailingAnchor).isActive = true
        contentBackgroundView.topAnchor.constraint(equalTo: roleImageView.bottomAnchor, constant: DuoOtherRoleCollectionViewCell.contentBackgroundViewAndRoleImageViewMargin).isActive = true

        contentLabel.leadingAnchor.constraint(equalTo: contentBackgroundView.leadingAnchor, constant: DuoOtherRoleCollectionViewCell.contentLabelMargin).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentBackgroundView.trailingAnchor, constant: -DuoOtherRoleCollectionViewCell.contentLabelMargin).isActive = true
        contentLabel.topAnchor.constraint(equalTo: contentBackgroundView.topAnchor, constant: DuoOtherRoleCollectionViewCell.contentLabelMargin).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: contentBackgroundView.bottomAnchor, constant: -DuoOtherRoleCollectionViewCell.contentLabelMargin).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - Internal
    func setScoredChapter(_ scoredChapter: ScoredChapter) {
        let role = scoredChapter.chapter.role
        roleImageView.image = RoleUtils.avatarImage(with: role)
        roleLabel.text = NSLocalizedString("RoleAText", comment: "")
        contentLabel.text = scoredChapter.chapter.content
    }

    class func cellHeight(with width: CGFloat, scoredChapter: ScoredChapter) -> CGFloat {
        let contentWidth = width - leadingMargin - roleImageViewSize - roleImageViewAndroleLabelMargin - 2 * contentLabelMargin - trailingMargin
        sizingCell.contentLabel.text = scoredChapter.chapter.content
        let contentHeight = sizingCell.contentLabel.sizeThatFits(CGSize.init(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)).height
        return roleImageViewSize + contentBackgroundViewAndRoleImageViewMargin + contentHeight + 2 * contentLabelMargin
    }

}
