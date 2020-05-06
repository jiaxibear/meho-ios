//
//  PinyinDelimiterView.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/22/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class PinyinDelimiterView: UIView {

    // MARK: - properties
    public let delimiterHeight = CGFloat(20)
    private let delimiterLineThick = CGFloat(1)
    private let titleFontSize = CGFloat(15)
    private let lineAndTitleMargin = CGFloat(15)

    // MARK: - properties
    private let leftLine = UIView.init(frame: .zero)
    private let rightLine = UIView.init(frame: .zero)
    private let titleLabel = UILabel.init(frame: .zero)

    // MARK: - data


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
        setupTitleLabel()
        setupLines()
    }

    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let fontDescriptor = UIFont.systemFont(ofSize: titleFontSize, weight: .regular).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        titleLabel.textColor = .textBlueGray
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: delimiterHeight).isActive = true
    }

    func setupLines() {
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.backgroundColor = .textBlueGray
        addSubview(leftLine)
        leftLine.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -lineAndTitleMargin).isActive = true
        leftLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: lineAndTitleMargin).isActive = true
        leftLine.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        leftLine.heightAnchor.constraint(equalToConstant: delimiterLineThick).isActive = true

        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.backgroundColor = .textBlueGray
        addSubview(rightLine)
        rightLine.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: lineAndTitleMargin).isActive = true
        rightLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -lineAndTitleMargin).isActive = true
        rightLine.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        rightLine.heightAnchor.constraint(equalToConstant: delimiterLineThick).isActive = true
    }

    func setTitle(title: String) {
        titleLabel.text = title
    }
}
