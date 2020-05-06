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

    // MARK: - Properties
    private let titleEnLabel = UILabel.init(frame: .zero)
    private static var sizingView = OneLineTitleHeaderCollectionReusableView.init(frame: .zero)

    private var titleEn = ""

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

        // Sets up the title
        titleEnLabel.text = titleEn
        titleEnLabel.textColor = .black
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleEnLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        titleEnLabel.numberOfLines = 3
        titleEnLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleEnLabel)


        // Sets up layout constrainsts.
        titleEnLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleEnLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleEnLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLableTopMargin).isActive = true
        titleEnLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -titleBottomMargin).isActive = true
    }

    public func setTitle(titleEn: String) {
        titleEnLabel.text = titleEn
        titleEnLabel.sizeToFit()
    }

    public class func heightForTitle(with width: CGFloat, titleEn: String) -> CGFloat {
        sizingView.setTitle(titleEn: titleEn)
        let titleEnLabelHeight = sizingView.titleEnLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        return titleEnLabelHeight + sizingView.titleLableTopMargin + sizingView.titleBottomMargin
    }
}
