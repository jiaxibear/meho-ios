//
//  DisplayScoreSwitch.swift
//  meho-ios
//
//  Created by Meho Dev on 7/11/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class DisplayScoreSwitch: UIView {

    private let titleLabelFontSize = CGFloat(16)
    private let titleLabelAndToggleSwitchMargin = CGFloat(6)

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .wisteriaPurple
        titleLabel.text = NSLocalizedString("ScoreText", comment: "")
        let titleLabelFontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: titleLabelFontDescriptor!, size: titleLabelFontSize)
        return titleLabel
    } ()

    lazy var toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch.init(frame: .zero)
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.onTintColor = .wisteriaPurple
        return toggleSwitch
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [titleLabel, toggleSwitch])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
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
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    // MARK: - UIView
    override var intrinsicContentSize: CGSize {
        let titleLabelIntrinsicContentSize = titleLabel.intrinsicContentSize
        let toggleSwitchIntrinsicContentSize = toggleSwitch.intrinsicContentSize
        let height = max(titleLabelIntrinsicContentSize.height, toggleSwitchIntrinsicContentSize.height)
        let width = titleLabelIntrinsicContentSize.width + titleLabelAndToggleSwitchMargin + toggleSwitchIntrinsicContentSize.width
        return CGSize.init(width: width, height: height)
    }
}
