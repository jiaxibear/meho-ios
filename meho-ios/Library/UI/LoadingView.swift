//
//  LoadingView.swift
//  meho-ios
//
//  Created by Meho Dev on 2/23/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    // MARK: - Constants
    private let imageViewWidth = CGFloat(200)
    private let imageViewHeight = CGFloat(200)
    private let imageViewTopMargin = CGFloat(120)
    private let titleLabelFontSize = CGFloat(20)

    // MARK: - Properties
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.loadGifFromLocal(name: "Loading@3x")
        return imageView
    } ()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("LoadingText", comment: "")
        titleLabel.textColor = .slateGrey
        titleLabel.font = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .light)
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

        addSubview(imageView)
        addSubview(titleLabel)
        let layoutGuide = UILayoutGuide.init()
        addLayoutGuide(layoutGuide)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: imageViewTopMargin),

            layoutGuide.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            layoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            layoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            layoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor)
        ])
    }
}
