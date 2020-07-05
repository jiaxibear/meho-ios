//
//  CollapsedChapterCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 3/21/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class CollapsedChapterCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let contentLabelFontSize = CGFloat(24)
    private let contentPinyinLabelFontSize = CGFloat(16)
    private let contentInLocalLanguageLabelFontSize = CGFloat(16)
    private let contentLeadingTrailingMargin = CGFloat(50)
    private let contentTopBottomMargin = CGFloat(20)
    private let contentsMargin = CGFloat(12)
    private let scoreViewAlpha = CGFloat(0.5)
    private let scoreViewTralingMargin = CGFloat(16)
    private let bottomSeparatorViewHeight = CGFloat(1)
    private let bottomSeparatorViewLeadingTrailingMargin = CGFloat(20)

    // MARK: - Properties
    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel.init(frame: .zero)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .textBlueGray
        contentLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: contentLabelFontSize)
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        return contentLabel
    } ()

    private lazy var contentPinyinLabel: UILabel = {
        let contentPinyinLabel = UILabel.init(frame: .zero)
        contentPinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPinyinLabel.textColor = .textBlueGray
        let contentPinyinFontDescriptor = UIFont.systemFont(ofSize: contentPinyinLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        contentPinyinLabel.font = UIFont.init(descriptor: contentPinyinFontDescriptor!, size: contentPinyinLabelFontSize)
        contentPinyinLabel.numberOfLines = 0
        contentPinyinLabel.textAlignment = .center
        return contentPinyinLabel
    } ()

    private lazy var contentInLocalLanguageLabel: UILabel = {
        let contentInLocalLanguageLabel = UILabel.init(frame: .zero)
        contentInLocalLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentInLocalLanguageLabel.textColor = .textBlueGray
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

    private lazy var bottomSeparatorView: UIView = {
        let bottomSeparatorView = UIView.init(frame: .zero)
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparatorView.backgroundColor = .separator
        return bottomSeparatorView
    } ()

    private static var sizingCell = CollapsedChapterCollectionViewCell.init(frame: .zero);

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(contentLabel)
        contentView.addSubview(scoreView)
        contentView.addSubview(contentPinyinLabel)
        contentView.addSubview(contentInLocalLanguageLabel)
        contentView.addSubview(bottomSeparatorView)

        // Sets up layout constraints
        scoreView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        scoreView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -scoreViewTralingMargin).isActive = true

        contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentLeadingTrailingMargin).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentLeadingTrailingMargin).isActive = true
        contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentTopBottomMargin).isActive = true

        contentPinyinLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        contentPinyinLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
        contentPinyinLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: contentsMargin).isActive = true

        contentInLocalLanguageLabel.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor).isActive = true
        contentInLocalLanguageLabel.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor).isActive = true
        contentInLocalLanguageLabel.topAnchor.constraint(equalTo: contentPinyinLabel.bottomAnchor, constant: contentsMargin).isActive = true
        contentInLocalLanguageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentTopBottomMargin).isActive = true

        bottomSeparatorView.heightAnchor.constraint(equalToConstant: bottomSeparatorViewHeight).isActive = true
        bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: bottomSeparatorViewLeadingTrailingMargin).isActive = true
        bottomSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -bottomSeparatorViewLeadingTrailingMargin).isActive = true
        bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bottomSeparatorViewHeight).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - Internal
    func setScoredChapter(_ scoredChapter: ScoredChapter) {
        contentLabel.text = scoredChapter.chapter.content
        contentPinyinLabel.text = scoredChapter.chapter.contentPinyin
        contentInLocalLanguageLabel.text = scoredChapter.chapter.contentInLocalLanguage
        scoreView.setScore(scoredChapter.score)
    }

    class func cellHeight(with width: CGFloat, chapter: Chapter) -> CGFloat {
        sizingCell.contentLabel.text = chapter.content
        sizingCell.contentPinyinLabel.text = chapter.contentPinyin
        sizingCell.contentInLocalLanguageLabel.text = chapter.contentInLocalLanguage
        var height = sizingCell.contentTopBottomMargin * 2 + sizingCell.contentsMargin * 2
        let contentWidth = width - 2 * sizingCell.contentLeadingTrailingMargin
        height += sizingCell.contentLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        height += sizingCell.contentPinyinLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        height += sizingCell.contentInLocalLanguageLabel.sizeThatFits(CGSize.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        return height
    }
}
