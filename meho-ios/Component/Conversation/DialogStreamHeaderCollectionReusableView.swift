//
//  DialogStreamHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 3/20/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol DialogStreamHeaderCollectionReusableViewDelegate : AnyObject {
    func dialogStreamHeaderCollectionReusableViewDidTapDifficultyButton(_ view: DialogStreamHeaderCollectionReusableView)
}

class DialogStreamHeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - Constants
    private let titleFontSize = CGFloat(24)
    private let difficultyButtonFontSize = CGFloat(16)

    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let difficultyButton = UIButton.init(frame: .zero)
    weak var delegate: DialogStreamHeaderCollectionReusableViewDelegate?

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

        // Sets up difficulty button.
        difficultyButton.setTitleColor(.textBlueGray, for: .normal)
        let difficultyButtonFontDescriptor = UIFont.systemFont(ofSize: difficultyButtonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        difficultyButton.titleLabel?.font = UIFont.init(descriptor: difficultyButtonFontDescriptor!, size: difficultyButtonFontSize)
        difficultyButton.translatesAutoresizingMaskIntoConstraints = false
        difficultyButton.addTarget(self, action: #selector(didTapDifficultyButton(_:)), for: .touchUpInside)
        self.addSubview(difficultyButton)

        // Sets up constraints
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        difficultyButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        difficultyButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - Public
    public func setTitle(_ title: String) {
        titleLabel.text = title
    }

    public func setDifficulty(_ difficulty: Difficulty) {
        difficultyButton.isHidden = false
        difficultyButton.setTitle(difficulty.title, for: .normal)
        difficultyButton.sizeToFit()
    }

    public class func heightForTitle(_ title: String) -> CGFloat {
        let label = UILabel.init(frame: .zero)
        label.text = title
        label.sizeToFit()
        return label.frame.height
    }

    // MARK: - Private
    @objc
    func didTapDifficultyButton(_ button: UIButton) {
        delegate?.dialogStreamHeaderCollectionReusableViewDidTapDifficultyButton(self)
    }
}
