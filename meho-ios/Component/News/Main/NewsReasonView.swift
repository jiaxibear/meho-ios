//
//  NewsReasonView.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/4/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class NewsReasonView: UIView {
    // MARK: - Constants
    private let yellowViewWidth = CGFloat(9)
    private let yellowViewHeight = CGFloat(27)
    private let reasonLabelFontSize = CGFloat(16)
    private let yellowViewAndReasonLabelMargin = CGFloat(6)

    // MARK: - Properties
    private let yellowView = UIView.init(frame: .zero)
    private let reasonLabel = UILabel.init(frame: .zero)
    private var showYellowBar = true
    private var isDarkMode = false

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect, yellowBar: Bool, darkMode: Bool)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(frame: CGRect, yellowBar: Bool, darkMode: Bool)")
    }

    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("Use init(frame: CGRect, yellowBar: Bool, darkMode: Bool)")
    }

    init(frame: CGRect, yellowBar: Bool, darkMode: Bool) {
        super.init(frame: frame)
        showYellowBar = yellowBar
        isDarkMode = darkMode
        backgroundColor = .white

        // Sets up yellow view.
        yellowView.backgroundColor = .sunYellow
        yellowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(yellowView)

        // Sets up reason label.
        let reasonfontDescriptor = UIFont.systemFont(ofSize: reasonLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        reasonLabel.font = UIFont.init(descriptor: reasonfontDescriptor!, size: reasonLabelFontSize)
        reasonLabel.textColor = .textBlueGray
        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
        reasonLabel.numberOfLines = 3
        if isDarkMode {
            reasonLabel.textColor = .white
            backgroundColor = .clear
        }
        addSubview(reasonLabel)

        // Sets up constraints
        let yellowViewWidthToUse = showYellowBar ? yellowViewWidth : 0
        let yellowViewMarginToUse = showYellowBar ? yellowViewAndReasonLabelMargin : 0
        yellowView.widthAnchor.constraint(equalToConstant: yellowViewWidthToUse).isActive = true
        yellowView.heightAnchor.constraint(equalTo: reasonLabel.heightAnchor).isActive = true
        yellowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        yellowView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        reasonLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: yellowViewHeight).isActive = true
        reasonLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        reasonLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        reasonLabel.leadingAnchor.constraint(equalTo: yellowView.trailingAnchor, constant: yellowViewMarginToUse).isActive = true
    }

    public func setReasonText(text: String) {
        reasonLabel.text = text
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width
        let yellowViewWidthToSubtract = showYellowBar ? yellowViewWidth + yellowViewAndReasonLabelMargin : 0
        let reasonLabelWidth = width - yellowViewWidthToSubtract
        let height = max(yellowViewHeight, reasonLabel.sizeThatFits(CGSize.init(width: reasonLabelWidth, height: size.height)).height)
        return CGSize.init(width: width, height: height)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 0, height: max(yellowViewHeight, reasonLabel.intrinsicContentSize.height))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let yellowViewWidthToSubtract = showYellowBar ? yellowViewWidth + yellowViewAndReasonLabelMargin : 0
        reasonLabel.preferredMaxLayoutWidth = bounds.size.width - yellowViewWidthToSubtract
        invalidateIntrinsicContentSize()
    }
}
