//
//  ProfileDummyCardCollectionViewCell.swift
//  meho-ios
//
//  Created by Meho Dev on 11/18/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ProfileDummyCardCollectionViewCell: UICollectionViewCell {

    private let dotViewWidth = CGFloat(8)
    private let dotViewHeight = CGFloat(8)
    private let dotsStackViewSpacing = CGFloat(16)

    private lazy var dotView1: UIView = {
        return createDotView()
    } ()

    private lazy var dotView2: UIView = {
        return createDotView()
    } ()

    private lazy var dotView3: UIView = {
        return createDotView()
    } ()

    private lazy var dotsStackView: UIStackView = {
        let dotsStackView = UIStackView.init(arrangedSubviews: [dotView1, dotView2, dotView3])
        dotsStackView.translatesAutoresizingMaskIntoConstraints = false
        dotsStackView.axis = .horizontal
        dotsStackView.alignment = .center
        dotsStackView.spacing = dotsStackViewSpacing
        return dotsStackView
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
        contentView.backgroundColor = .lightBlueGrey
        contentView.addSubview(dotsStackView)

        NSLayoutConstraint.activate([
            dotView1.widthAnchor.constraint(equalToConstant: dotViewWidth),
            dotView1.heightAnchor.constraint(equalToConstant: dotViewHeight),
            dotView2.widthAnchor.constraint(equalToConstant: dotViewWidth),
            dotView2.heightAnchor.constraint(equalToConstant: dotViewHeight),
            dotView3.widthAnchor.constraint(equalToConstant: dotViewWidth),
            dotView3.heightAnchor.constraint(equalToConstant: dotViewHeight),

            dotsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dotsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dotsStackView.heightAnchor.constraint(equalToConstant: dotViewHeight),
            dotsStackView.widthAnchor.constraint(equalToConstant: dotViewWidth * 3 + 2 * dotsStackViewSpacing)
        ])
    }

    // MARK: - Private
    func createDotView() -> UIView {
        let dotView = UIView.init(frame: .zero)
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = .white
        dotView.clipsToBounds = true
        dotView.layer.cornerRadius = dotViewHeight / 2
        return dotView
    }
}
