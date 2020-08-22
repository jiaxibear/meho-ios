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

    // MARK: - Properties
    private let titleEnLabel = UILabel.init(frame: .zero)
    private let titleZhLabel = UILabel.init(frame: .zero)
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
        titleZhLabel.text = titleZh
        titleZhLabel.textColor = .black
        titleZhLabel.font = UIFont.init(name: "PingFangSC-Semibold", size: titleLabelFontSize)
        titleZhLabel.numberOfLines = 3
        titleZhLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleZhLabel)

        titleEnLabel.text = titleEn
        titleEnLabel.textColor = .black
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleEnLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        titleEnLabel.numberOfLines = 3
        titleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleEnLabel)

        // Sets up layout constrainsts.
        titleZhLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleZhLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleZhLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLableTopMargin).isActive = true

        titleEnLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleEnLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleEnLabel.topAnchor.constraint(equalTo: titleZhLabel.bottomAnchor, constant: titleInsets).isActive = true
        titleEnLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -titleBottomMargin).isActive = true
    }

    public func setTitle(titleEn: String, titleZh: String) {
        titleEnLabel.text = titleEn.trimmingCharacters(in: .whitespacesAndNewlines)
        titleZhLabel.text = titleZh.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public class func heightForTitle(with width: CGFloat, titleEn: String, titleZh: String) -> CGFloat {
        sizingView.setTitle(titleEn: titleEn, titleZh: titleZh)
        let titleEnLabelHeight = sizingView.titleEnLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        let titleZhLabelHeight = sizingView.titleZhLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        return titleEnLabelHeight + sizingView.titleLableTopMargin + sizingView.titleInsets + titleZhLabelHeight + sizingView.titleBottomMargin
    }
}
