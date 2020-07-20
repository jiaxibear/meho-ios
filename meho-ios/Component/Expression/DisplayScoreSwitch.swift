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
    }

}
