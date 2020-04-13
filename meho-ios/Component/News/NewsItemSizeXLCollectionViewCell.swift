//
//  NewsFeaturedCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 3/29/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsItemSizeXLCollectionViewCell: UICollectionViewCell, WebImageViewDelegate {
    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(21)
    private let titleLabelLeadingTrailingMargin = CGFloat(12)
    private let titleLabelToBottomMargin = CGFloat(6)

    private let reasonLabelLeadingTrailingMargin = CGFloat(13)
    private let reasonLabelAndTitleLabelMargin = CGFloat(8)

    private let coverImageViewHeight = CGFloat(320)
    private let coverImageViewCornerRadius = CGFloat(8)


    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let reasonView = NewsReasonView.init(frame: .zero)
    private let coverImageView = WebImageView.init(frame: .zero)
    private static var sizingCell = NewsItemSizeXLCollectionViewCell.init(frame: .zero);
    private let gradientLayer = CAGradientLayer()

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
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.layer.cornerRadius = coverImageViewCornerRadius
        coverImageView.clipsToBounds = true
        coverImageView.delegate = self
        contentView.addSubview(coverImageView)

        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(1).cgColor]
        coverImageView.layer.insertSublayer(gradientLayer, at: 0)

        // Sets up title label.
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        let labelfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: labelfontDescriptor!, size: 0)
        contentView.addSubview(titleLabel)

        // Sets up reason label.
        reasonView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reasonView)


        // Sets up constraints
        coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: coverImageViewHeight).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor, constant: titleLabelLeadingTrailingMargin).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: -titleLabelLeadingTrailingMargin).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -titleLabelToBottomMargin).isActive = true

        reasonView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor, constant: reasonLabelLeadingTrailingMargin).isActive = true
        reasonView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: -reasonLabelLeadingTrailingMargin).isActive = true
        reasonView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -reasonLabelAndTitleLabelMargin).isActive = true

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
            coverImageView.imageURL = coverImageURL
        }
    }

    public class func cellHeight(with width: CGFloat, news: News) -> CGFloat {
        return sizingCell.coverImageViewHeight
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = frame
    }
}
