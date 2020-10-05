//
//  ProfileHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 10/4/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Constants
    private let topLineViewHeight = CGFloat(1)
    private let titleLabelFontSize = CGFloat(18)
    private let titleLabelLeadingMargin = CGFloat(18)

    // MARK: - Models
    var profileHeader: ProfileHeader! {
        didSet {
            titleLabel.text = profileHeader.title
        }
    }

    // MARK: - UI
    private lazy var topLineView: UIView = {
        let topLineView = UIView.init(frame: .zero)
        topLineView.translatesAutoresizingMaskIntoConstraints = false
        topLineView.backgroundColor = .lightBlueGreyTwo
        return topLineView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .darkGrayTwo
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)!
        titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor, size: titleLabelFontSize)
        return titleLabel
    } ()

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
        addSubview(topLineView)
        addSubview(titleLabel)

        topLineView.heightAnchor.constraint(equalToConstant: topLineViewHeight).isActive = true
        topLineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topLineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: titleLabelLeadingMargin).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
