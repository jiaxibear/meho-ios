//
//  MustKnowPhraseCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 11/12/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

protocol MustKnowPhraseCollectionViewCellDelegate : AnyObject {
    func mustKnowPhraseCollectionViewCellDidTapSaveButton(scoredChapter: ScoredChapter, currentIsSaved: Bool)
}

class MustKnowPhraseCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let quoteLabelFontSize = CGFloat(30)
    private let contentLabelFontSize = CGFloat(20)
    private let contentPinyinLabelFontSize = CGFloat(16)
    private let contentInLocalLanguageLabelFontSize = CGFloat(16)
    private let contentLeadingTrailingMargin = CGFloat(60)
    private let contentTopMargin = CGFloat(4)
    private let contentBottomMargin = CGFloat(20)
    private let contentsMargin = CGFloat(6)
    private let scoreViewAlpha = CGFloat(0.5)
    private let scoreViewTralingMargin = CGFloat(16)
    private let contentViewCornerRadius = CGFloat(8)
    private let contentViewShadowRadius = CGFloat(6)
    private let saveButtonWidth = CGFloat(30)
    private let saveButtonHeight = CGFloat(30)

    // MARK: - Properties
    private lazy var leftQuoteLabel: UILabel = {
        let leftQuoteLabel = UILabel.init(frame: .zero)
        leftQuoteLabel.translatesAutoresizingMaskIntoConstraints = false
        leftQuoteLabel.textColor = .wisteriaPurple
        leftQuoteLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: quoteLabelFontSize)
        leftQuoteLabel.numberOfLines = 1
        leftQuoteLabel.textAlignment = .left
        leftQuoteLabel.text = "\""
        return leftQuoteLabel
    } ()

    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel.init(frame: .zero)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .darkGrayTwo
        contentLabel.font = UIFont.init(name: "PingFangSC-Medium", size: contentLabelFontSize)
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        return contentLabel
    } ()

    private lazy var rightQuoteLabel: UILabel = {
        let rightQuoteLabel = UILabel.init(frame: .zero)
        rightQuoteLabel.translatesAutoresizingMaskIntoConstraints = false
        rightQuoteLabel.textColor = .wisteriaPurple
        rightQuoteLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: quoteLabelFontSize)
        rightQuoteLabel.numberOfLines = 1
        rightQuoteLabel.textAlignment = .right
        rightQuoteLabel.text = "\""
        return rightQuoteLabel
    } ()

    private lazy var contentPinyinLabel: UILabel = {
        let contentPinyinLabel = UILabel.init(frame: .zero)
        contentPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPinyinLabel.textColor = .mehoDarkGray
        let contentPinyinFontDescriptor = UIFont.systemFont(ofSize: contentPinyinLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        contentPinyinLabel.font = UIFont.init(descriptor: contentPinyinFontDescriptor!, size: contentPinyinLabelFontSize)
        contentPinyinLabel.numberOfLines = 0
        contentPinyinLabel.textAlignment = .center
        return contentPinyinLabel
    } ()

    private lazy var contentInLocalLanguageLabel: UILabel = {
        let contentInLocalLanguageLabel = UILabel.init(frame: .zero)
        contentInLocalLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentInLocalLanguageLabel.textColor = .mehoDarkGray
        let contentInLocalLanguageFontDescriptor = UIFont.systemFont(ofSize: contentInLocalLanguageLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        contentInLocalLanguageLabel.font = UIFont.init(descriptor: contentInLocalLanguageFontDescriptor!, size: contentInLocalLanguageLabelFontSize)
        contentInLocalLanguageLabel.numberOfLines = 0
        contentInLocalLanguageLabel.textAlignment = .center
        return contentInLocalLanguageLabel
    } ()

    private lazy var scoreView: ChapterScoreView = {
        let scoreView = ChapterScoreView.init(frame: .zero)
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        scoreView.alpha = scoreViewAlpha
        return scoreView
    } ()

    private lazy var saveButton: UIButton = {
        let saveButton = UIButton.init(frame: .zero)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        let saveButtonUnsavedImage = UIImage.init(named: "purple_saved_unfilled")
        let saveButtonSavedImage = UIImage.init(named: "purple_saved_filled")
        saveButton.setImage(saveButtonUnsavedImage, for: .normal)
        saveButton.setImage(saveButtonSavedImage, for: .selected)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        saveButton.isHidden = true
        return saveButton
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [leftQuoteLabel, contentLabel, rightQuoteLabel, contentPinyinLabel, contentInLocalLanguageLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .fill
        contentStackView.spacing = contentsMargin
        contentStackView.setCustomSpacing(-contentsMargin * 3, after: leftQuoteLabel)
        contentStackView.setCustomSpacing(-contentsMargin, after: contentLabel)
        return contentStackView;
    } ()

    weak var delegate: MustKnowPhraseCollectionViewCellDelegate?
    private var scoredChapter: ScoredChapter!

    private static var sizingCell = MustKnowPhraseCollectionViewCell.init(frame: .zero)

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.shadowColor = UIColor.paleLilac.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
        layer.shadowRadius = contentViewShadowRadius
        layer.backgroundColor = UIColor.clear.cgColor

        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.borderColor = UIColor.paleLilac.cgColor
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.backgroundColor = .white

        contentView.addSubview(contentStackView)
        contentView.addSubview(scoreView)
        contentView.addSubview(saveButton)

        // Sets up layout constraints
        NSLayoutConstraint.activate([
            scoreView.centerYAnchor.constraint(equalTo: contentLabel.centerYAnchor),
            scoreView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -scoreViewTralingMargin),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentTopMargin),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentBottomMargin),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentLeadingTrailingMargin),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentLeadingTrailingMargin),

            saveButton.widthAnchor.constraint(equalToConstant: saveButtonWidth),
            saveButton.heightAnchor.constraint(equalToConstant: saveButtonHeight),
            saveButton.centerXAnchor.constraint(equalTo: scoreView.centerXAnchor),
            saveButton.centerYAnchor.constraint(equalTo: contentInLocalLanguageLabel.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - Internal
    func setScoredChapter(_ scoredChapter: ScoredChapter, isSelected: Bool) {
        if let scoredContent = scoredChapter.scoredContent {
            contentLabel.attributedText = scoredContent
        } else {
            contentLabel.attributedText = nil
            contentLabel.text = scoredChapter.chapter.content
        }
        contentPinyinLabel.text = scoredChapter.chapter.contentPinyin
        contentInLocalLanguageLabel.text = scoredChapter.chapter.contentInLocalLanguage
        if scoredChapter.shouldDisplayScore {
            scoreView.setScore(scoredChapter.score)
        } else {
            scoreView.isHidden = true
        }

        if isSelected {
            contentView.backgroundColor = UIColor.skyBlue.withAlphaComponent(0.1)
        } else {
            contentView.backgroundColor = .white
        }

        saveButton.isHidden = !scoredChapter.canBeSaved
        if !saveButton.isHidden, let isSaved = scoredChapter.isSaved {
            saveButton.isSelected = isSaved
        }
        self.scoredChapter = scoredChapter
    }

    func updateSaveStatus(scoredChapter: ScoredChapter) {
        if scoredChapter.contentID != self.scoredChapter.contentID {
            return
        }

        self.scoredChapter = scoredChapter
        saveButton.isHidden = !scoredChapter.canBeSaved
        if !saveButton.isHidden, let isSaved = scoredChapter.isSaved {
            saveButton.isSelected = isSaved
        }
    }

    class func cellHeight(with width: CGFloat, chapter: Chapter) -> CGFloat {
        sizingCell.contentLabel.text = chapter.content
        sizingCell.contentPinyinLabel.text = chapter.contentPinyin
        sizingCell.contentInLocalLanguageLabel.text = chapter.contentInLocalLanguage
        var height = sizingCell.contentTopMargin + sizingCell.contentBottomMargin - sizingCell.contentsMargin * 2
        let contentWidth = width - 2 * sizingCell.contentLeadingTrailingMargin
        let fittingSize = CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)
        height += sizingCell.leftQuoteLabel.sizeThatFits(fittingSize).height
        height += sizingCell.rightQuoteLabel.sizeThatFits(fittingSize).height
        height += sizingCell.contentLabel.sizeThatFits(fittingSize).height
        height += sizingCell.contentPinyinLabel.sizeThatFits(fittingSize).height
        height += sizingCell.contentInLocalLanguageLabel.sizeThatFits(fittingSize).height
        return height
    }

    @objc
    func didTapSaveButton() {
        delegate?.mustKnowPhraseCollectionViewCellDidTapSaveButton(scoredChapter: scoredChapter, currentIsSaved: saveButton.isSelected)
        saveButton.isSelected = !saveButton.isSelected
    }
}
