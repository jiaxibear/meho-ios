//
//  NewsChapterCollectionViewCell.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/13/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol NewsChapterCollectionViewCellDelegate : AnyObject {
    func NewsChapterCollectionViewCellDidTapVocabulary(vocabularyUrl: URL)
}

class NewsChapterCollectionViewCell: UICollectionViewCell, WebImageViewDelegate, UITextViewDelegate {

    // MARK: - Constant
    private let contentTextFontSize = CGFloat(18)
    private let textAndImageMargin = CGFloat(18)
    private let contentImageReservedHeight = CGFloat(219)
    private let contentImageViewCornerRadius = CGFloat(8)

    // MARK: - Properties
    private let textView = UITextView.init(frame: .zero)
    private let imageView = WebImageView.init(frame: .zero)
    private static var sizingCell = NewsChapterCollectionViewCell.init(frame: .zero);
    private var imageViewHeightConstraint: NSLayoutConstraint!
    private var imageViewToTextViewMarginConstraint: NSLayoutConstraint!
    private var textViewBottomConstraint: NSLayoutConstraint!
    private weak var delegate: NewsChapterCollectionViewCellDelegate?

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
        textView.text = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        // Sets up content image view.
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = contentImageViewCornerRadius
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.delegate = self
        contentView.addSubview(imageView)

        // Sets up title label.
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.textColor = .textCharcoalGrey
        textView.tintColor = .wisteriaPurple
        textView.delegate = self
        contentView.addSubview(textView)

        // Constraint
        textView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)

        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: contentImageReservedHeight)
        imageViewHeightConstraint.isActive = true
        imageViewToTextViewMarginConstraint = imageView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: textAndImageMargin)
    }

    // MARK: - WebImageViewDelegate
    func webImageViewDidSetImage(webImageView: WebImageView) {
        self.contentView.isHidden = false
    }

    // MARK: - Public
    func setDelegate(delegate: NewsChapterCollectionViewCellDelegate) {
        self.delegate = delegate
    }

    public func setNews(_ newsChapter: NewsChapter) {
        let attributedContent = NewsChapterCollectionViewCell.getChapterTextWithAttribute(content: newsChapter.content)
        textView.attributedText = attributedContent
        textView.sizeToFit()
        if newsChapter.language == "en-US" {
            let contentfontDescriptor = UIFont.systemFont(ofSize: contentTextFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
            textView.font = UIFont.init(descriptor: contentfontDescriptor!, size: 0)
        } else {
            textView.font = UIFont.init(name: "PingFangSC-Light", size: contentTextFontSize)
        }

        // Downloads the image.
        if let contentImageURL = newsChapter.contentImageURL {
            imageView.imageURL = contentImageURL
            imageViewHeightConstraint.constant = contentImageReservedHeight
            imageViewToTextViewMarginConstraint.isActive = true
            textViewBottomConstraint.isActive = false
        } else {
            imageViewHeightConstraint.constant = 0
            imageViewToTextViewMarginConstraint.isActive = false
            textViewBottomConstraint.isActive = true
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
        if newsChapter.contentImageURL != nil {
            height += sizingCell.textAndImageMargin
            height += sizingCell.contentImageReservedHeight
        }
        return height
    }

    private class func getChapterTextWithAttribute(content: String) -> NSMutableAttributedString {

        let htmlData = NSString(string: content).data(using: String.Encoding.unicode.rawValue)

        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]

        let attributedString = try! NSMutableAttributedString(data: htmlData!, options: options, documentAttributes: nil)

        // Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineSpacing = 6 // Design set line height, I only find how to set line spacing

        // Add line spacing attribute to string
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        /* perform your own custom actions here */
        delegate?.NewsChapterCollectionViewCellDidTapVocabulary(vocabularyUrl: URL.absoluteURL)
        return false // return true if you also want UIAlertController to pop up
    }


}


