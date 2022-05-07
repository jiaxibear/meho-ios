//
//  OneLineTitleHeaderCollectionReusableView.swift
//  meho-ios
//  Reusable header view for news, one line here specifically means English title, as compaired to TwiLineTitleHeaderCollectionReusableView meant for Chinese and English view
//
//  Created by Jiaxi Xiong on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class OneLineTitleHeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLableTopMargin = CGFloat(8) // marked as 18 to source subtitle, adjust as no navigationbar border
    private let titleBottomMargin = CGFloat(20)
    private let titleLabelFontSize = CGFloat(24)
    private let dateLabelFontSize = CGFloat(12)
    private let dateToTitleMargin = CGFloat(10)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.textColor = .black
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    } ()

    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel.init(frame: .zero)
        dateLabel.textColor = .black
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: dateLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        dateLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        dateLabel.numberOfLines = 0
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    } ()

    private static var sizingView = OneLineTitleHeaderCollectionReusableView.init(frame: .zero)

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(dateLabel)

        // Sets up layout constrainsts.
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLableTopMargin).isActive = true

        dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: dateToTitleMargin).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -titleBottomMargin).isActive = true
    }

    // MARK: - Internal
    func setHeader(title: String, maybeDate: String? = nil) {
        titleLabel.text = title.trimmingCharacters(in: .whitespacesAndNewlines)

        let dateFormatterFrom = DateFormatter()
        dateFormatterFrom.dateFormat = "yyyy-MM-dd"
        let dateFormatterTo = DateFormatter()
        dateFormatterTo.dateFormat = "MMM dd,yyyy"
        if let originalDate = maybeDate {
            dateLabel.isHidden = false
            if let formattedDate = dateFormatterFrom.date(from: originalDate) {
                dateLabel.text = dateFormatterTo.string(from: formattedDate)
            } else {
               print("There was an error decoding the string")
            }
        } else {
            dateLabel.isHidden = true
        }
    }

    class func heightForHeader(with width: CGFloat, title: String, maybeDate: String? = nil) -> CGFloat {
        sizingView.setHeader(title: title, maybeDate: maybeDate)
        let titleLabelHeight = sizingView.titleLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        let dateLabelHeight = sizingView.dateLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        let titleHeight = sizingView.titleLableTopMargin
            + titleLabelHeight
            + sizingView.titleBottomMargin
        if maybeDate != nil {
            return titleHeight + sizingView.dateToTitleMargin + dateLabelHeight
        } else {
            return titleHeight
        }
    }
}
