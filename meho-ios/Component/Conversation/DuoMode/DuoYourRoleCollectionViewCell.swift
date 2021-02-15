//
//  DuoYourRoleCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 4/26/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol DuoYourRoleCollectionViewCellDelegate : AnyObject {
    func duoYourRoleCollectionViewCellDidTapSpeakerButton(_ view: DuoYourRoleCollectionViewCell)
}

class DuoYourRoleCollectionViewCell: UICollectionViewCell {

    // MARK: - Constants
    private static let roleImageViewSize = CGFloat(30)
    private static let leadingMargin = CGFloat(56)
    private static let trailingMargin = CGFloat(16)
    private static let roleLabelFontSize = CGFloat(14)
    private static let roleImageViewAndroleLabelMargin = CGFloat(10)
    private static let contentBackgroundViewBackgroundColorAlpha = CGFloat(0.1)
    private static let contentBackgroundViewCornerRadius = CGFloat(10)
    private static let contentBackgroundViewAndRoleImageViewMargin = CGFloat(6)
    private static let contentLabelFontSize = CGFloat(18)
    private static let contentsLabelMargin = CGFloat(18)
    private static let contentPinyinLabelFontSize = CGFloat(14)
    private static let contentPinyinLabelAndContentLabelMargin = CGFloat(6)
    private static let speakerButtonSize = CGFloat(30)
    private static let speakerImageName = "conversation_speaker"

    // MARK: - Properties
    // MARK: UI
    private lazy var roleImageView: UIImageView = {
        let avatarImageView = UIImageView.init(frame: .zero)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = DuoYourRoleCollectionViewCell.roleImageViewSize / 2
        return avatarImageView
    } ()

    private lazy var roleLabel: UILabel = {
        let roleLabel = UILabel.init(frame: .zero)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.textColor = .textBlueGray
        roleLabel.textAlignment = .right
        let roleLabelFontDescriptor = UIFont.systemFont(ofSize: DuoYourRoleCollectionViewCell.roleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        roleLabel.font = UIFont.init(descriptor: roleLabelFontDescriptor!, size: DuoYourRoleCollectionViewCell.roleLabelFontSize)
        return roleLabel
    } ()

    private lazy var contentBackgroundView: UIView = {
        let contentBackgroundView = UIView.init(frame: .zero)
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentBackgroundView.clipsToBounds = true
        contentBackgroundView.layer.cornerRadius = DuoYourRoleCollectionViewCell.contentBackgroundViewCornerRadius
        contentBackgroundView.backgroundColor = UIColor.skyBlue.withAlphaComponent(DuoYourRoleCollectionViewCell.contentBackgroundViewBackgroundColorAlpha)
        return contentBackgroundView
    } ()

    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel.init(frame: .zero)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .mehoDarkGray
        contentLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: DuoYourRoleCollectionViewCell.contentLabelFontSize)
        contentLabel.numberOfLines = 0
        return contentLabel
    } ()

    private lazy var contentPinyinLabel: UILabel = {
        let contentPinyinLabel = UILabel.init(frame: .zero)
        contentPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPinyinLabel.textColor = .mehoDarkGray
        contentPinyinLabel.numberOfLines = 0
        let contentPinyinLabelFontDescriptor = UIFont.systemFont(ofSize: DuoYourRoleCollectionViewCell.contentPinyinLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        contentPinyinLabel.font = UIFont.init(descriptor: contentPinyinLabelFontDescriptor!, size: DuoYourRoleCollectionViewCell.contentPinyinLabelFontSize)
        return contentPinyinLabel
    } ()

    private lazy var speakerButton: UIButton = {
        let speakerButton = UIButton.init(frame: .zero)
        let speakerImage = UIImage.init(named: DuoYourRoleCollectionViewCell.speakerImageName)
        speakerButton.setImage(speakerImage, for: .normal)
        speakerButton.translatesAutoresizingMaskIntoConstraints = false
        speakerButton.clipsToBounds = true
        speakerButton.layer.cornerRadius = DuoYourRoleCollectionViewCell.speakerButtonSize / 2
        speakerButton.addTarget(self, action: #selector(didTapSpeakerButton), for: .touchUpInside)
        return speakerButton
    } ()

    private lazy var scoreView: ChapterScoreView = {
        let chapterScoreView = ChapterScoreView.init(frame: .zero)
        chapterScoreView.translatesAutoresizingMaskIntoConstraints = false
        return chapterScoreView
    } ()

    private static var sizingCell = DuoYourRoleCollectionViewCell.init(frame: .zero);

    // MARK: Model
    weak var delegate: DuoYourRoleCollectionViewCellDelegate?

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(roleImageView)
        contentView.addSubview(roleLabel)
        contentView.addSubview(contentBackgroundView)
        contentView.addSubview(speakerButton)
        contentView.addSubview(scoreView)
        contentBackgroundView.addSubview(contentLabel)
        contentBackgroundView.addSubview(contentPinyinLabel)

        roleImageView.widthAnchor.constraint(equalToConstant: DuoYourRoleCollectionViewCell.roleImageViewSize).isActive = true
        roleImageView.heightAnchor.constraint(equalToConstant: DuoYourRoleCollectionViewCell.roleImageViewSize).isActive = true
        roleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DuoYourRoleCollectionViewCell.trailingMargin).isActive = true
        roleImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        roleLabel.trailingAnchor.constraint(equalTo: roleImageView.leadingAnchor, constant: -DuoYourRoleCollectionViewCell.roleImageViewAndroleLabelMargin).isActive = true
        roleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DuoYourRoleCollectionViewCell.leadingMargin).isActive = true
        roleLabel.centerYAnchor.constraint(equalTo: roleImageView.centerYAnchor).isActive = true

        contentBackgroundView.leadingAnchor.constraint(equalTo: roleLabel.leadingAnchor).isActive = true
        contentBackgroundView.trailingAnchor.constraint(equalTo: roleLabel.trailingAnchor).isActive = true
        contentBackgroundView.topAnchor.constraint(equalTo: roleImageView.bottomAnchor, constant: DuoYourRoleCollectionViewCell.contentBackgroundViewAndRoleImageViewMargin).isActive = true

        contentLabel.leadingAnchor.constraint(equalTo: contentBackgroundView.leadingAnchor, constant: DuoYourRoleCollectionViewCell.contentsLabelMargin).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentBackgroundView.trailingAnchor, constant: -DuoYourRoleCollectionViewCell.contentsLabelMargin).isActive = true
        contentLabel.topAnchor.constraint(equalTo: contentBackgroundView.topAnchor, constant: DuoYourRoleCollectionViewCell.contentsLabelMargin).isActive = true

        contentPinyinLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        contentPinyinLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
        contentPinyinLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: DuoYourRoleCollectionViewCell.contentPinyinLabelAndContentLabelMargin).isActive = true
        contentPinyinLabel.bottomAnchor.constraint(equalTo: contentBackgroundView.bottomAnchor, constant: -DuoYourRoleCollectionViewCell.contentsLabelMargin).isActive = true

        speakerButton.widthAnchor.constraint(equalToConstant: DuoYourRoleCollectionViewCell.speakerButtonSize).isActive = true
        speakerButton.heightAnchor.constraint(equalToConstant: DuoYourRoleCollectionViewCell.speakerButtonSize).isActive = true
        speakerButton.centerXAnchor.constraint(equalTo: roleImageView.centerXAnchor).isActive = true
        speakerButton.centerYAnchor.constraint(equalTo: contentBackgroundView.centerYAnchor).isActive = true

        scoreView.centerXAnchor.constraint(equalTo: speakerButton.centerXAnchor).isActive = true
        scoreView.centerYAnchor.constraint(equalTo: speakerButton.centerYAnchor).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - Internal
    func setScoredChapter(_ scoredChapter: ScoredChapter, isActive: Bool, name: String) {
        let chapter = scoredChapter.chapter
        let role = chapter.role
        roleImageView.image = RoleUtils.avatarImage(with: role)
        roleLabel.text = name
        contentLabel.text = chapter.content
        contentPinyinLabel.text = chapter.contentPinyin
        if isActive {
            speakerButton.isHidden = false
            if let scoredContent = scoredChapter.scoredContent {
                contentLabel.attributedText = scoredContent
            } else {
                contentLabel.textColor = .mehoDarkGray
            }
            contentPinyinLabel.textColor = .mehoDarkGray
            contentBackgroundView.backgroundColor = UIColor.skyBlue.withAlphaComponent(DuoYourRoleCollectionViewCell.contentBackgroundViewBackgroundColorAlpha)
        } else {
            speakerButton.isHidden = true
            contentLabel.textColor = .textBlueGray
            contentPinyinLabel.textColor = .textBlueGray
            contentBackgroundView.backgroundColor = .paleGray
        }
        let score = scoredChapter.score
        if score > -1 {
            speakerButton.isHidden = true
            scoreView.isHidden = false
            scoreView.setScore(score)
        } else {
            speakerButton.isHidden = false
            scoreView.isHidden = true
        }
    }

    class func cellHeight(with width: CGFloat, scoredChapter: ScoredChapter) -> CGFloat {
        let contentWidth = width - leadingMargin - roleImageViewSize - roleImageViewAndroleLabelMargin - 2 * contentsLabelMargin - trailingMargin
        let contentFittingSize = CGSize.init(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)
        let chapter = scoredChapter.chapter
        sizingCell.contentLabel.text = chapter.content
        let contentHeight = sizingCell.contentLabel.sizeThatFits(contentFittingSize).height
        sizingCell.contentPinyinLabel.text = chapter.contentPinyin
        let contentPinyinHeight = sizingCell.contentPinyinLabel.sizeThatFits(contentFittingSize).height
        return roleImageViewSize + contentBackgroundViewAndRoleImageViewMargin + contentHeight + contentPinyinLabelAndContentLabelMargin + contentPinyinHeight + 2 * contentsLabelMargin
    }

    // MARK: - Private
    @objc func didTapSpeakerButton() {
        delegate?.duoYourRoleCollectionViewCellDidTapSpeakerButton(self)
    }
}
