//
//  BulletPointView.swift
//  meho-ios
//
//  Created by Meho Dev on 6/28/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class BulletPointView: UIView {

    // MARK: - Constants
    private let bulletViewSideLength = CGFloat(4)
    private let pointLabelFontSize = CGFloat(12)
    private let pointLabelLeadingMargin = CGFloat(10)

    // MARK: - Properties
    private lazy var pointLabel: UILabel = {
        let pointLabel = UILabel.init(frame: .zero)
        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        pointLabel.textColor = .textCharcoalGrey
        let pointLabelFontDescriptor = UIFont.systemFont(ofSize: pointLabelFontSize).fontDescriptor.withDesign(.rounded)
        pointLabel.font = UIFont.init(descriptor: pointLabelFontDescriptor!, size: pointLabelFontSize)
        return pointLabel
    } ()

    private lazy var bulletView: UIView = {
        let bulletView = UIView.init(frame: .zero)
        bulletView.translatesAutoresizingMaskIntoConstraints = false
        bulletView.layer.cornerRadius = bulletViewSideLength / 2
        bulletView.clipsToBounds = true
        return bulletView
    } ()

    var bulletColor: UIColor = .wisteriaPurple {
        didSet {
            bulletView.backgroundColor = bulletColor
        }
    }

    var pointText: String? {
        didSet {
            pointLabel.text = pointText
        }
    }

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
        addSubview(bulletView)
        addSubview(pointLabel)

        bulletView.widthAnchor.constraint(equalToConstant: bulletViewSideLength).isActive = true
        bulletView.heightAnchor.constraint(equalToConstant: bulletViewSideLength).isActive = true
        bulletView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bulletView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        pointLabel.leadingAnchor.constraint(equalTo: bulletView.trailingAnchor, constant: pointLabelLeadingMargin).isActive = true
        pointLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pointLabel.centerYAnchor.constraint(equalTo: bulletView.centerYAnchor).isActive = true
    }

    // MARK: - UIView
    override var intrinsicContentSize: CGSize {
        let pointLabelIntrinsicContentSize = pointLabel.intrinsicContentSize
        return CGSize.init(width: pointLabelIntrinsicContentSize.width + bulletViewSideLength + pointLabelLeadingMargin, height: pointLabelIntrinsicContentSize.height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let maxWidth = size.width
        let maxHeight = size.height
        let pointLabelMaxWidth = maxWidth - bulletViewSideLength - pointLabelLeadingMargin
        let pointLabelSize = pointLabel.sizeThatFits(CGSize.init(width: pointLabelMaxWidth, height: maxHeight))
        return CGSize.init(width: bulletViewSideLength + pointLabelLeadingMargin + pointLabelSize.width, height: pointLabelSize.height)
    }
}
