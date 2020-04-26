//
//  MainTabTitleView.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/26/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class MainTabTitleView: UIView {

    // MARK: - Constants
    private let dummypProfileImageName = "conversation_facepile1"
    private let titleLabelFontSize = CGFloat(34)
    private let titleLableTopMargin = CGFloat(8)
    private let viewHeight = CGFloat(40)

    // MARK: - Properties
    private let titleLabel = UILabel.init(frame: .zero)
    private let profileButton = UIButton.init(frame: .zero)

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
        setupProfileButton()
    }

    private func setupTitleLabel() {
        // Sets up the title
        titleLabel.textColor = .wisteriaPurple
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .white
        let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)
        titleLabel.font = UIFont.init(descriptor: fontDescriptor!, size: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Sets up layout constrainsts.
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLableTopMargin).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func setupProfileButton() {
        let profileImage = UIImage.init(named:dummypProfileImageName)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.setImage(profileImage, for: .normal)
        addSubview(profileButton)

        profileButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        profileButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        profileButton.widthAnchor.constraint(equalToConstant: viewHeight).isActive = true
    }

    public func setTitleText(text: String) {
        titleLabel.text = text
    }

    public func getViewHeight() -> CGFloat {
        return viewHeight
    }

}
