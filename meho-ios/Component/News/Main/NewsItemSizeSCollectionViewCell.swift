//
//  NewsWithImageCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 3/29/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol NewsItemSizeSCollectionViewCellDelegate: AnyObject {
    func newsItemSizeSCollectionViewCellDidTapPlayAudioButton(news: News)
}

class NewsItemSizeSCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(18)
    private let reasonLabelFontSize = CGFloat(16)
    private let labelsStackViewAndThumbnailViewMargin = CGFloat(14)
    private let thumbnailImageSideLength = CGFloat(120)
    private let thumbnailImageViewCornerRadius = CGFloat(8)
    private let playAudioButtonWidth = CGFloat(30)
    private let playAudioButtonHeight = CGFloat(30)
    private let dateLabelFontSize = CGFloat(12)
    private let thirdLineStackViewSpacing = CGFloat(16)
    private let labelsStackViewSpacing = CGFloat(10)

    // MARK: - Properties
    var delegate: NewsItemSizeSCollectionViewCellDelegate?

    private lazy var playAudioButton: UIButton = {
        let playAudioButton = UIButton.init(frame: .zero)
        playAudioButton.translatesAutoresizingMaskIntoConstraints = false
        let playAudioButtonImage = UIImage.init(named: "stories_purple_headphone_play")
        playAudioButton.setImage(playAudioButtonImage, for: .normal)
        playAudioButton.addTarget(self, action: #selector(didTapPlayAudioButton), for: .touchUpInside)
        return playAudioButton
    } ()

    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel.init(frame: .zero)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        var dateLabelFont = UIFont.systemFont(ofSize: dateLabelFontSize)
        if let dateLabelFontDescriptor = dateLabelFont.fontDescriptor.withDesign(.rounded) {
            dateLabelFont = UIFont.init(descriptor: dateLabelFontDescriptor, size: dateLabelFontSize)
        }
        dateLabel.font = dateLabelFont
        return dateLabel
    } ()

    private lazy var thirdLineStackView: UIStackView = {
        let thirdLineStackView = UIStackView.init(arrangedSubviews: [playAudioButton, dateLabel])
        thirdLineStackView.translatesAutoresizingMaskIntoConstraints = false
        thirdLineStackView.axis = .horizontal
        thirdLineStackView.spacing = thirdLineStackViewSpacing
        return thirdLineStackView
    } ()

    private lazy var labelsStackView: UIStackView = {
        let labelsStackView = UIStackView.init(arrangedSubviews: [titleLabel, reasonView, thirdLineStackView])
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.spacing = labelsStackViewSpacing
        return labelsStackView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        let labelfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: labelfontDescriptor!, size: 0)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return titleLabel
    } ()

    private lazy var reasonView: NewsReasonView = {
        let reasonView = NewsReasonView.init(frame: .zero, yellowBar: false, darkMode: false)
        reasonView.translatesAutoresizingMaskIntoConstraints = false
        return reasonView
    } ()

    private lazy var thumbnailImageView: WebImageView = {
        let thumbnailImageView = WebImageView.init(frame: .zero)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.layer.cornerRadius = thumbnailImageViewCornerRadius
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        return thumbnailImageView
    } ()

    private lazy var thirdLineStackViewHeightAnchor: NSLayoutConstraint = {
        return thirdLineStackView.heightAnchor.constraint(equalToConstant: 0)
    } ()

    private static var sizingCell = NewsItemSizeSCollectionViewCell.init(frame: .zero);

    var news: News? {
        didSet {
            if let news = news {
                titleLabel.text = news.title_en

                // Sets the reason text
                reasonView.setReasonText(text: news.reason)

                // Downloads the image.
                if let coverImageURL = news.coverImageURL {
                    thumbnailImageView.imageURL = coverImageURL
                } else if let imageKey = news.imageKey {
                    thumbnailImageView.imageKey = imageKey
                }

                dateLabel.text = news.date
                thirdLineStackViewHeightAnchor.constant = thirdLineStackViewHeight(width: contentView.bounds.width)
                if news.audioEnKey == nil {
                    playAudioButton.isHidden = true
                }
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
        backgroundColor = .white

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(labelsStackView)

        NSLayoutConstraint.activate([
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: thumbnailImageSideLength),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: thumbnailImageSideLength),
            playAudioButton.widthAnchor.constraint(equalToConstant: playAudioButtonWidth),
            playAudioButton.heightAnchor.constraint(equalToConstant: playAudioButtonHeight),
            labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -labelsStackViewAndThumbnailViewMargin),
        ])
    }

    public class func cellHeight(with width: CGFloat, news: News) -> CGFloat {
        sizingCell.news = news
        let labelMaxWidth = width - sizingCell.thumbnailImageSideLength - sizingCell.labelsStackViewAndThumbnailViewMargin
        let labelFittingSize = CGSize.init(width: labelMaxWidth, height: .greatestFiniteMagnitude)
        var height = sizingCell.titleLabel.sizeThatFits(labelFittingSize).height + sizingCell.reasonView.sizeThatFits(labelFittingSize).height + sizingCell.labelsStackViewSpacing
        if news.audioEnKey != nil {
            height += sizingCell.thirdLineStackViewHeight(width: width) + 2 * sizingCell.labelsStackViewSpacing
        }
        return max(height, sizingCell.thumbnailImageSideLength)
    }

    private func thirdLineStackViewHeight(width: CGFloat) -> CGFloat {
        var dateLabelMaxtWidth = width - thumbnailImageSideLength - labelsStackViewAndThumbnailViewMargin
        if news?.audioEnKey != nil {
            dateLabelMaxtWidth -= playAudioButtonWidth + thirdLineStackViewSpacing
        }
        let dateLabelHeight = dateLabel.sizeThatFits(CGSize.init(width: dateLabelMaxtWidth, height: .greatestFiniteMagnitude)).height
        return max(dateLabelHeight, playAudioButtonHeight)
    }

    @objc
    private func didTapPlayAudioButton() {
        if let news = news {
            delegate?.newsItemSizeSCollectionViewCellDidTapPlayAudioButton(news: news)
        }
    }
}
