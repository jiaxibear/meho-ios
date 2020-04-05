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

        // Sets up yellow view.
        yellowView.backgroundColor = .sunYellow
        yellowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(yellowView)

        // Sets up reason label.
        let reasonfontDescriptor = UIFont.systemFont(ofSize: reasonLabelFontSize, weight: .thin).fontDescriptor.withDesign(.rounded)
        reasonLabel.font = UIFont.init(descriptor: reasonfontDescriptor!, size: reasonLabelFontSize)
        reasonLabel.textColor = .darkGrayTwo
        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
        reasonLabel.numberOfLines = 2
        addSubview(reasonLabel)

        // Sets up constraints
        yellowView.widthAnchor.constraint(equalToConstant: yellowViewWidth).isActive = true
        yellowView.heightAnchor.constraint(equalTo: reasonLabel.heightAnchor).isActive = true
        yellowView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        yellowView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        reasonLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: yellowViewHeight).isActive = true
        reasonLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        reasonLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        reasonLabel.leadingAnchor.constraint(equalTo: yellowView.trailingAnchor, constant: yellowViewAndReasonLabelMargin).isActive = true
    }

    public func setReasonText(text: String) {
        reasonLabel.text = text
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width
        let reasonLabelWidth = width - yellowViewWidth - yellowViewAndReasonLabelMargin
        let height = max(yellowViewHeight, reasonLabel.sizeThatFits(CGSize.init(width: reasonLabelWidth, height: size.height)).height)
        return CGSize.init(width: width, height: height)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 0, height: max(yellowViewHeight, reasonLabel.intrinsicContentSize.height))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        reasonLabel.preferredMaxLayoutWidth = bounds.size.width - yellowViewWidth - yellowViewAndReasonLabelMargin
        invalidateIntrinsicContentSize()
    }
}
