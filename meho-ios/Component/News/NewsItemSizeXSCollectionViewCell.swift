//
//  NewsItemSizeXSCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/3/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsItemSizeXSCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(18)
    private let titleLabelLeadingTrailingMargin = CGFloat(12)
    private let titleLabelToBottomMargin = CGFloat(6)

    private let reasonLabelFontSize = CGFloat(16)
    private let reasonLabelLeadingTrailingMargin = CGFloat(13)

    private let reasonLabelAndTitleLabelMargin = CGFloat(8)
    private let titleLabelAndThumbnailViewMargin = CGFloat(9)


    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let reasonView = NewsReasonView.init(frame: .zero)
    private static var sizingCell = NewsItemSizeXSCollectionViewCell.init(frame: .zero);


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

        // Sets up title label.
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGray
        let labelfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: labelfontDescriptor!, size: 0)
        contentView.addSubview(titleLabel)

        // Sets up reason label.
        reasonView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reasonView)


        // Sets up constraints
        reasonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        reasonView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        reasonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true


        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: reasonView.bottomAnchor, constant: reasonLabelAndTitleLabelMargin).isActive = true

    }

    // MARK: - Public
    public func setNews(_ news: News) {
        // Sets the text for the title label.
        titleLabel.text = news.title

        // Sets the reason text
        reasonView.setReasonText(text: news.reason)
    }

    public class func cellHeight(with width: CGFloat, news: News) -> CGFloat {
        sizingCell.titleLabel.text = news.title
        sizingCell.reasonView.setReasonText(text: news.reason)
        let height = sizingCell.reasonView.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
            + sizingCell.reasonLabelAndTitleLabelMargin
            + sizingCell.titleLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
        return height
    }
}
