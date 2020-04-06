//
//  ChapterScoreView.swift
//  meho-ios
//
//  Created by Meho Dev on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ChapterScoreView: UIView {
    // MARK: - Constants
    private let width = CGFloat(30)
    private let height = CGFloat(38)
    private let scoreLabelFontSize = CGFloat(18)
    private let scoreLabelTopMargin = CGFloat(6)
    private let scoreImageName = "conversation_score_frame"

    // MARK: - Properties
    private let backgroundImageView = UIImageView.init(frame: .zero)
    private let scoreLabel = UILabel.init(frame: .zero)

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
        let scoreImage = UIImage.init(named: scoreImageName)
        backgroundImageView.image = scoreImage
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)

        scoreLabel.textColor = .white
        let scoreLabelFontDescriptor = UIFont.systemFont(ofSize: scoreLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded)
        scoreLabel.font = UIFont.init(descriptor: scoreLabelFontDescriptor!, size: scoreLabelFontSize)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scoreLabel)

        // Sets up the layout constraints.
        backgroundImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: topAnchor, constant: scoreLabelTopMargin).isActive = true
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
            scoreLabel.text = String(Int(score))
        }
    }
}
