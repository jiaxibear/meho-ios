//
//  NewsChapterCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/13/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol NewsChapterCollectionViewCellDelegate : AnyObject {
    func NewsChapterCollectionViewCellDidTapVocabulary(vocabularyId: String)
}

class NewsChapterCollectionViewCell: UICollectionViewCell, WebImageViewDelegate, UITextViewDelegate {

    // MARK: - Constant
    private let contentTextFontSize = CGFloat(18)
    private let textAndImageMargin = CGFloat(18)
    private let contentImageReservedHeight = CGFloat(219)
    private let contentImageViewCornerRadius = CGFloat(8)

    // MARK: - Properties
    private lazy var textView: UITextView = {
        let textView = UITextView.init(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.textColor = .textCharcoalGrey
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.wisteriaPurple,
            NSAttributedString.Key.underlineColor: UIColor.lightGray,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.patternDot.rawValue | NSUnderlineStyle.byWord.rawValue
        ]
        textView.linkTextAttributes = linkAttributes
        return textView
    } ()

    private lazy var imageView: WebImageView = {
        let imageView = WebImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = contentImageViewCornerRadius
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.delegate = self
        return imageView
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [textView, imageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    } ()

    private static var sizingCell = NewsChapterCollectionViewCell.init(frame: .zero);

    private lazy var imageViewHeightConstraint: NSLayoutConstraint = {
        return imageView.heightAnchor.constraint(equalToConstant: contentImageReservedHeight)
    } ()

    private lazy var textViewHeightConstraint: NSLayoutConstraint = {
        return textView.heightAnchor.constraint(equalToConstant: 0)
    } ()

    private weak var delegate: NewsChapterCollectionViewCellDelegate?

    var newsChapter: NewsChapter! {
        didSet {
            let attributedContent = NewsChapterCollectionViewCell.getChapterTextWithAttribute(chapter: newsChapter)
            textView.attributedText = attributedContent
            textView.sizeToFit()
            if newsChapter.language == "en-US" {
                let contentfontDescriptor = UIFont.systemFont(ofSize: contentTextFontSize, weight: .light).fontDescriptor.withDesign(.rounded)
                textView.font = UIFont.init(descriptor: contentfontDescriptor!, size: 0)
            } else {
                textView.font = UIFont.init(name: "PingFangSC-Light", size: contentTextFontSize)
            }

            // Downloads the image.
            if let contentImageURL = newsChapter.contentImageURL {
                imageView.imageURL = contentImageURL
                imageView.isHidden = false
            } else if let imageKey = newsChapter.image_key, let imageBucket = newsChapter.image_bucket {
                let s3Key = S3ImageViewKey.init(bucket: imageBucket, key: imageKey)
                imageView.imageKey = s3Key
                imageView.isHidden = false
            } else {
                imageView.isHidden = true
            }
            stackView.spacing = textAndImageMargin
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

    override func prepareForReuse() {
        imageView.image = nil
        imageView.isHidden = true
        textView.text = nil
        imageViewHeightConstraint.isActive = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        contentView.addSubview(stackView)

        // Constraint
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    override func updateConstraints() {
        super.updateConstraints()
        if newsChapter.contentImageURL != nil || (newsChapter.image_key != nil && newsChapter.image_bucket != nil) {
            imageViewHeightConstraint.isActive = true
        }
    }

    // MARK: - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
        imageView.isHidden = false
    }

    // MARK: - Internal
    func setDelegate(delegate: NewsChapterCollectionViewCellDelegate) {
        self.delegate = delegate
    }

    class func cellHeight(with width: CGFloat, newsChapter: NewsChapter) -> CGFloat {
        let attributedContent = getChapterTextWithAttribute(chapter: newsChapter)
        sizingCell.textView.attributedText = attributedContent
        if newsChapter.language == "en-US" {
            let contentfontDescriptor = UIFont.systemFont(ofSize: sizingCell.contentTextFontSize, weight: .light).fontDescriptor.withDesign(.rounded)
            sizingCell.textView.font = UIFont.init(descriptor: contentfontDescriptor!, size: 0)
        } else {
            sizingCell.textView.font = UIFont.init(name: "PingFangSC-Light", size: sizingCell.contentTextFontSize)
        }

        var height = sizingCell.textView.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
        if newsChapter.contentImageURL != nil || (newsChapter.image_key != nil && newsChapter.image_bucket != nil) {
            height += sizingCell.textAndImageMargin
            height += sizingCell.contentImageReservedHeight
        }
        return height
    }

    private class func getChapterTextWithAttribute(chapter: NewsChapter) -> NSMutableAttributedString {
        let attributedContent = NSMutableAttributedString(string: chapter.content.trimmingCharacters(in: .whitespacesAndNewlines))

        // Add links
        let vocabularyList = chapter.vocabularies
        var ranges: [NSRange] = []
        for vocab in vocabularyList {
            let vocabOffset = vocab.chapter_offset
            guard vocabOffset != -1 else { continue }
            let range = NSRange(location: vocabOffset, length: vocab.content_zh.count)
            attributedContent.addAttribute(.link, value: vocab.identifier, range: range)
            ranges.append(range)
        }
        ranges.sort {$0.location < $1.location}

        // Add space
        let newAttributedString = NSMutableAttributedString.init(attributedString: attributedContent)
        var indexOffset = 0
        for (index, range) in ranges.enumerated() {
            if index < ranges.count - 1 {
                if range.location + range.length == ranges[index + 1].location {
                    newAttributedString.insert(NSAttributedString.init(string: " "), at: ranges[index + 1].location + indexOffset)
                    indexOffset = indexOffset + 1
                }
            }
        }

        // Add line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2 // Design set line height, I only find how to set line spacing

        // Add line spacing attribute to string
        newAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, newAttributedString.length))

        return newAttributedString
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        /* perform your own custom actions here */
        let id:String = URL.absoluteString
        delegate?.NewsChapterCollectionViewCellDidTapVocabulary(vocabularyId: id)
        return false // return true if you also want UIAlertController to pop up
    }
}


