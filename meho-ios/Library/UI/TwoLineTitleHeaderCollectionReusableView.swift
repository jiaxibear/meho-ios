//
//  NewsTwoTitleHeaderCollectionReusableView.swift
//  meho-ios
//  Reusable header view for news, two line here specifically meant for Chinese and English view, as compared to OneLineTitleHeaderCollectionReusableView only has English title view
//
//  Created by Jiaxi Xiong on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class TwoLineTitleHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLableTopMargin = CGFloat(8) // marked as 18 to source subtitle, adjust as no navigationbar border
    private let titleBottomMargin = CGFloat(20)
    private let titleLabelFontSize = CGFloat(24)
    private let titleInsets = CGFloat(5)
    private let dateLabelFontSize = CGFloat(12)
    private let dateToTitleMargin = CGFloat(10)

    // MARK: - Properties
    private lazy var titleEnLabel:UILabel = {
        let titleEnLabel = UILabel.init(frame: .zero)
        titleEnLabel.text = titleEn
        titleEnLabel.textColor = .black
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleEnLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        titleEnLabel.numberOfLines = 0
        titleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleEnLabel
    } ()

    private lazy var titleZhLabel:UILabel = {
        let titleZhLabel = UILabel.init(frame: .zero)
        titleZhLabel.text = titleZh
        titleZhLabel.textColor = .black
        titleZhLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: titleLabelFontSize)
        titleZhLabel.numberOfLines = 0
        titleZhLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleZhLabel
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
    
    private static var sizingView = TwoLineTitleHeaderCollectionReusableView.init(frame: .zero)

    private var titleEn = ""
    private var titleZh = ""

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
        setupTitleView()
    }

    private func setupTitleView() {
        // Sets up the title.
        addSubview(titleZhLabel)
        addSubview(titleEnLabel)
        addSubview(dateLabel)

        // Sets up layout constrainsts.
        titleZhLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleZhLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleZhLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLableTopMargin).isActive = true

        titleEnLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleEnLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleEnLabel.topAnchor.constraint(equalTo: titleZhLabel.bottomAnchor, constant: titleInsets).isActive = true

        dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo: titleEnLabel.bottomAnchor, constant: dateToTitleMargin).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -titleBottomMargin).isActive = true
    }

    public func setHeader(titleEn: String, titleZh: String, maybeDate: String? = nil) {
        titleEnLabel.text = titleEn.trimmingCharacters(in: .whitespacesAndNewlines)
        titleZhLabel.text = titleZh.trimmingCharacters(in: .whitespacesAndNewlines)

        let dateFormatterFrom = DateFormatter()
        dateFormatterFrom.dateFormat = "yyyy-MM-dd"
        let dateFormatterTo = DateFormatter()
        dateFormatterTo.locale = Locale(identifier: "zh_CN")
        dateFormatterTo.dateFormat = "YYYY年MM月dd日"
        if let originalDate = maybeDate {
            if let formattedDate = dateFormatterFrom.date(from: originalDate) {
                dateLabel.text = dateFormatterTo.string(from: formattedDate)
            } else {
               print("There was an error decoding the string")
            }
        }
    }

    public class func heightForHeader(with width: CGFloat, titleEn: String, titleZh: String, maybeDate: String? = nil) -> CGFloat {
        sizingView.setHeader(titleEn: titleEn, titleZh: titleZh, maybeDate:maybeDate)
        let titleEnLabelHeight = sizingView.titleEnLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        let titleZhLabelHeight = sizingView.titleZhLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        let dateLabelHeight = sizingView.dateLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        let titleHeight = titleEnLabelHeight + sizingView.titleLableTopMargin + sizingView.titleInsets + titleZhLabelHeight + sizingView.titleBottomMargin
        if maybeDate != nil  {
            return titleHeight + dateLabelHeight + sizingView.dateToTitleMargin
        } else {
            return titleHeight
        }
    }
}
