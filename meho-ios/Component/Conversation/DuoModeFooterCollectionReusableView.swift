//
//  DualModeFooterCollectionReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 4/25/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol DuoModeFooterCollectionResuableViewDelegate : AnyObject {
    func duoModeFooterCollectionResuableViewDidTapButton(_ view: DuoModeFooterCollectionResuableView)
}

class DuoModeFooterCollectionResuableView: UICollectionReusableView {
    // MARK: - Constants
    private static let duoModeButtonHeight = CGFloat(40)
    private static let duoModeButtonCornerRadius = CGFloat(18)
    private static let duoModeButtonFontSize = CGFloat(14)
    private static let duoMoreButtonWidth = CGFloat(210)
    private static let topBottomMargin = CGFloat(20)
    internal static let viewHeight = {
        return duoModeButtonHeight + 2 * topBottomMargin;
    }()

    // MARK: - Properties
    lazy var duoModeButton: UIButton = {
        let duoModeButton = UIButton.init(frame: .zero)
        let duoModeButtonTitle = NSLocalizedString("DuoModeButtonTitle", comment: "")
        duoModeButton.setTitle(duoModeButtonTitle, for: .normal)
        duoModeButton.layer.cornerRadius = DuoModeFooterCollectionResuableView.duoModeButtonCornerRadius
        duoModeButton.backgroundColor = .skyBlue
        duoModeButton.setTitleColor(.white, for: .normal)
        let duoModeButtonFontDescriptor = UIFont.systemFont(ofSize: DuoModeFooterCollectionResuableView.duoModeButtonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        duoModeButton.titleLabel?.font = UIFont.init(descriptor: duoModeButtonFontDescriptor!, size: DuoModeFooterCollectionResuableView.duoModeButtonFontSize)
        duoModeButton.translatesAutoresizingMaskIntoConstraints = false
        duoModeButton.addTarget(self, action: #selector(didTapDuoModeButton), for: .touchUpInside)
        return duoModeButton
    }()
    weak var delegate: DuoModeFooterCollectionResuableViewDelegate?

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(duoModeButton)

        // Sets up layout constraints.
        duoModeButton.topAnchor.constraint(equalTo: topAnchor, constant: DuoModeFooterCollectionResuableView.topBottomMargin).isActive = true
        duoModeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DuoModeFooterCollectionResuableView.topBottomMargin).isActive = true
        duoModeButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        duoModeButton.heightAnchor.constraint(equalToConstant: DuoModeFooterCollectionResuableView.duoModeButtonHeight).isActive = true
        duoModeButton.widthAnchor.constraint(equalToConstant: DuoModeFooterCollectionResuableView.duoMoreButtonWidth).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }


    // MARK: - Private
    @objc
    func didTapDuoModeButton() {
        delegate?.duoModeFooterCollectionResuableViewDidTapButton(self)
    }
}
