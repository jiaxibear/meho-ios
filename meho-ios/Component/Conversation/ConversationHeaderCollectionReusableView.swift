//
//  ConversationHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 3/7/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ConversationHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Constants
    private let titleFontSize = CGFloat(24)

    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Sets up title label.
        titleLabel.textColor = .darkGrayTwo
        let titleFontDescriptor = UIFont.systemFont(ofSize: titleFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: titleFontDescriptor!, size: titleFontSize)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)

        // Sets up constraints
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - Public
    public func setTitle(_ title: String) {
        titleLabel.text = title
    }

    public class func heightForTitle(_ title: String) -> CGFloat {
        let label = UILabel.init(frame: .zero)
        label.text = title
        label.sizeToFit()
        return label.frame.height
    }
}
