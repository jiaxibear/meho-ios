//
//  NewsListHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsListHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Constants
    private let trailingLeadingMargin = CGFloat(22)
    private let titleLableTopMargin = CGFloat(8) // marked as 18 to source subtitle, adjust as no navigationbar border
    private let titleBottomMargin = CGFloat(20)
    private let titleLabelFontSize = CGFloat(34)

    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private static var sizingView = NewsListHeaderCollectionReusableView.init(frame: .zero)

    private var title = ""

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
        titleLabel.text = NSLocalizedString("NewsTitle", comment: "")
        titleLabel.textColor = .wisteriaPurple
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .white
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)


        // Sets up layout constrainsts.
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLableTopMargin).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -titleBottomMargin).isActive = true
    }

    public func setTitle(title: String) {
        titleLabel.text = title
    }

    public class func heightForTitle(with width: CGFloat, title: String) -> CGFloat {
        sizingView.setTitle(title: title)
        let titleEnLabelHeight = sizingView.titleLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        return titleEnLabelHeight + sizingView.titleLableTopMargin + sizingView.titleBottomMargin
    }
}
