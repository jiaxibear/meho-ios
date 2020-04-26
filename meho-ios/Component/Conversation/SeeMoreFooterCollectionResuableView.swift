//
//  SeeMoreCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 3/8/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

protocol SeeMoreFooterCollectionResuableViewDelegate : AnyObject {
    func seeMoreFooterCollectionResuableViewDidTapButton(_ view: SeeMoreFooterCollectionResuableView)
}

class SeeMoreFooterCollectionResuableView: UICollectionReusableView {

    // MARK: - Constants
    let seeMoreButtonBorderWidth = CGFloat(1)
    let seeMoreButtonFontSize = CGFloat(13)
    let seeMoreButtonWidth = CGFloat(135)
    let seeMoreButtonCornerRadius = CGFloat(8)
    let bottomMargin = CGFloat(16)

    // MARK: - Properties
    let seeMoreButton = UIButton.init(frame: .zero)
    weak var delegate: SeeMoreFooterCollectionResuableViewDelegate?

    // MARK: - Init
    @available(*, unavailable)
    init() {
        fatalError("Use init(frame: CGRect)")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let seeMoreButtonTitle = NSLocalizedString("SeeMoreButtonTitle", comment: "")
        seeMoreButton.setTitle(seeMoreButtonTitle, for: .normal)
        seeMoreButton.layer.borderColor = UIColor.black.cgColor
        seeMoreButton.layer.borderWidth = seeMoreButtonBorderWidth
        seeMoreButton.layer.cornerRadius = seeMoreButtonCornerRadius
        seeMoreButton.setTitleColor(.textCharcoalGrey, for: .normal)
        let seeMoreButtonFontDescriptor = UIFont.systemFont(ofSize: seeMoreButtonFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        seeMoreButton.titleLabel?.font = UIFont.init(descriptor: seeMoreButtonFontDescriptor!, size: seeMoreButtonFontSize)
        seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
        seeMoreButton.addTarget(self, action: #selector(didTapSeeMoreButton), for: .touchUpInside)
        addSubview(seeMoreButton)

        // Sets up layout constraints.
        seeMoreButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        seeMoreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomMargin).isActive = true
        seeMoreButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        seeMoreButton.widthAnchor.constraint(equalToConstant: seeMoreButtonWidth).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - Private
    @objc
    func didTapSeeMoreButton() {
        delegate?.seeMoreFooterCollectionResuableViewDidTapButton(self)
    }
}
