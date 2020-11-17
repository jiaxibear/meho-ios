//
//  NewsWithImageCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 3/29/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsItemSizeSCollectionViewCell: UICollectionViewCell, WebImageViewDelegate {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(18)
    private let titleLabelLeadingTrailingMargin = CGFloat(12)
    private let titleLabelToBottomMargin = CGFloat(6)

    private let reasonLabelFontSize = CGFloat(16)
    static let reasonLabelLeadingTrailingMargin = CGFloat(13)

    private let reasonLabelAndTitleLabelMargin = CGFloat(10)
    private let titleLabelAndThumbnailViewMargin = CGFloat(9)

    private let thumbnailImageSideLength = CGFloat(120)
    private let thumbnailImageViewCornerRadius = CGFloat(8)

    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let reasonView = NewsReasonView.init(frame: .zero, yellowBar: false, darkMode: false)
    private let thumbnailImageView = WebImageView.init(frame: .zero)
    private static var sizingCell = NewsItemSizeSCollectionViewCell.init(frame: .zero);

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

        // Sets up cover image view.
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.layer.cornerRadius = thumbnailImageViewCornerRadius
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.delegate = self
        contentView.addSubview(thumbnailImageView)

        // Sets up title label.
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        let labelfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: labelfontDescriptor!, size: 0)
        contentView.addSubview(titleLabel)

        // Sets up reason label.
        reasonView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reasonView)

        // Sets up constraints

        thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: thumbnailImageSideLength).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalToConstant: thumbnailImageSideLength).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -titleLabelAndThumbnailViewMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true

        reasonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        reasonView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: reasonLabelAndTitleLabelMargin).isActive = true
        reasonView.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -titleLabelAndThumbnailViewMargin).isActive = true
    }

    // MARK - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
        self.contentView.isHidden = false
    }

    // MARK: - Public
    public func setNews(_ news: News) {
        // Sets the text for the title label.
        titleLabel.text = news.title_en

        // Sets the reason text
        reasonView.setReasonText(text: news.reason)

        // Downloads the image.
        if let coverImageURL = news.coverImageURL {
            thumbnailImageView.imageURL = coverImageURL
        }
        if let imageKey = news.imageKey {
            thumbnailImageView.imageKey = imageKey
        }
    }

    public class func cellHeight(with width: CGFloat, news: News) -> CGFloat {
        sizingCell.titleLabel.text = news.title_en
        sizingCell.reasonView.setReasonText(text: news.reason)
        let titleAndReasonHeight = sizingCell.reasonView.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
            + sizingCell.reasonLabelAndTitleLabelMargin
            + sizingCell.titleLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
        return max(titleAndReasonHeight, sizingCell.thumbnailImageSideLength)
    }
}
