//
//  NewsChapterCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/13/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsChapterCollectionViewCell: UICollectionViewCell, WebImageViewDelegate {

    // MARK: - Constant
    private let contentTextFontSize = CGFloat(18)
    private let textAndImageMargin = CGFloat(18)
    private let contentImageReservedHeight = CGFloat(219)
    private let contentImageViewCornerRadius = CGFloat(8)

    // MARK: - Properties
    private let textView = UILabel.init(frame: .zero)
    private let imageView = WebImageView.init(frame: .zero)
    private static var sizingCell = NewsChapterCollectionViewCell.init(frame: .zero);

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


        // Sets up content image view.
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = contentImageViewCornerRadius
        imageView.clipsToBounds = true
        imageView.delegate = self
        contentView.addSubview(imageView)

        // Sets up title label.
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.numberOfLines = 0
        textView.textColor = .textCharcoalGrey
        contentView.addSubview(textView)

        // Constraint
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: contentImageReservedHeight).isActive = true
        imageView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: textAndImageMargin).isActive = true
    }

    // MARK: - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
        self.contentView.isHidden = false
    }

    // MARK: - Public
    public func setNews(_ newsChapter: NewsChapter) {
        let attributedContent = NewsChapterCollectionViewCell.getChapterTextWithAttribute(content: newsChapter.content)
        textView.attributedText = attributedContent
        textView.sizeToFit()
        if newsChapter.language == "en-US" {
            let contentfontDescriptor = UIFont.systemFont(ofSize: contentTextFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
            textView.font = UIFont.init(descriptor: contentfontDescriptor!, size: 0)
        } else {
            textView.font = UIFont.init(name: "PingFangSC-Semibold", size: contentTextFontSize)
        }


        // Downloads the image.
        if let contentImageURL = newsChapter.contentImageURL {
            imageView.imageURL = contentImageURL
        }
    }

    public class func cellHeight(with width: CGFloat, newsChapter: NewsChapter) -> CGFloat {
        let attributedContent = getChapterTextWithAttribute(content: newsChapter.content)
        sizingCell.textView.attributedText = attributedContent
        if newsChapter.language == "en-US" {
            let contentfontDescriptor = UIFont.systemFont(ofSize: sizingCell.contentTextFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
            sizingCell.textView.font = UIFont.init(descriptor: contentfontDescriptor!, size: 0)
        } else {
            sizingCell.textView.font = UIFont.init(name: "PingFangSC-Semibold", size: sizingCell.contentTextFontSize)
        }

        var height = sizingCell.textView.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
        if let contentImageURL = newsChapter.contentImageURL {
            height += sizingCell.textAndImageMargin
            height += sizingCell.contentImageReservedHeight
        }
        return height
    }

    private class func getChapterTextWithAttribute(content: String) -> NSMutableAttributedString {
        // Sets the text for the title label.

        let attributedString = NSMutableAttributedString(string: content)

        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()

        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 10 // Design set line height, I only find how to set line spacing

        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
}
