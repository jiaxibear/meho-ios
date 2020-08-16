//
//  ChapterScoreView.swift
//  meho-ios
//
//  Created by Meho Dev on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ChapterScoreView: UILabel {
    // MARK: - Constants
    private let width = CGFloat(36)
    private let height = CGFloat(36)
    private let scoreLabelFontSize = CGFloat(20)

    // MARK: - Properties

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

        // Sets up the score image view.
        textColor = .white
        backgroundColor = .skyBlue
        textAlignment = .center
        let scoreLabelFontDescriptor = UIFont.systemFont(ofSize: scoreLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        font = UIFont.init(descriptor: scoreLabelFontDescriptor!, size: scoreLabelFontSize)
        clipsToBounds = true
        layer.cornerRadius = width / 2
    }

    // MARK: - UIView
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: width, height: height)
    }

    // MARK: - Internal
    func setScore(_ score: Float) {
        if score < 0 {
            isHidden = true
        } else {
            isHidden = false
            text = String(Int(score))
        }
    }
}
