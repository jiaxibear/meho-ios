//
//  QuestionHeaderReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 8/16/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class QuestionHeaderReusableView: UICollectionReusableView {

    // MARK: - Constants
    private let titleLabelFontSize = CGFloat(18)

    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor!, size: titleLabelFontSize)
        titleLabel.numberOfLines = 0
        return titleLabel
    } ()

    private static var sizingView = QuestionHeaderReusableView.init(frame: .zero)

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
        addSubview(titleLabel)

        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: - Internal
    func setTitle(title: String) {
        titleLabel.text = title
    }

    class func heightForTitle(with width: CGFloat, title: String) -> CGFloat {
        sizingView.setTitle(title: title)
        let titleLabelHeight = sizingView.titleLabel.sizeThatFits(CGSize.init(width: width, height:CGFloat.greatestFiniteMagnitude)).height
        return titleLabelHeight
    }
}
