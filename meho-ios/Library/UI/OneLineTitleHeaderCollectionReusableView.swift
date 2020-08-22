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
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.textColor = .black
        let languageToggleEnfontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: languageToggleEnfontDescriptor!, size: 0)
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
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

        // Sets up layout constrainsts.
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLableTopMargin).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -titleBottomMargin).isActive = true
    }

    // MARK: - Internal
    func setTitle(title: String) {
        titleLabel.text = title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    class func heightForTitle(with width: CGFloat, title: String) -> CGFloat {
        sizingView.setTitle(title: title)
        let titleLabelHeight = sizingView.titleLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        return titleLabelHeight + sizingView.titleLableTopMargin + sizingView.titleBottomMargin
    }
}
