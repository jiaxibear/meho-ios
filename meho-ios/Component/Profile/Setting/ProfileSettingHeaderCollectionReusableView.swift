//
//  ProfileSettingHeaderCollectionReusableView.swift
//  meho-ios
//
//  Created by Meho Dev on 9/12/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit

class ProfileSettingHeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - Constants
    private let avatarImageViewWidth = CGFloat(80)
    private let avatarImageViewHeight = CGFloat(80)
    private let nameLabelFontSize = CGFloat(26)
    private let customSpacing = CGFloat(12)
    private static var sizingView = ProfileSettingHeaderCollectionReusableView.init(frame: .zero)

    // MARK: - Properties
    private lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView.init()
        avatarImageView.layer.cornerRadius = avatarImageViewWidth / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage.init(named: "no_profile_pic")
        return avatarImageView
    } ()

    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel.init(frame: .zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        // TODO: Use the real nick name
        nameLabel.text = userNickName
        nameLabel.textColor = .wisteriaPurple
        let nameLabelFontDescriptor = UIFont.systemFont(ofSize: nameLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded)!
        nameLabel.font = UIFont.init(descriptor: nameLabelFontDescriptor, size: nameLabelFontSize)
        nameLabel.textAlignment = .center
        return nameLabel
    } ()

    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView.init(arrangedSubviews: [avatarImageView, nameLabel])
        contentStackView.alignment = .center
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.spacing = customSpacing
        return contentStackView
    } ()

    var userNickName: String {
        didSet {
            nameLabel.text = userNickName
        }
    }

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
        self.userNickName = NSLocalizedString("UserDefaultNickname", comment: "")
        super.init(frame: frame)
        addSubview(contentStackView)
        contentStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: avatarImageViewHeight).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: avatarImageViewWidth).isActive = true
    }

    // MARK: - Internal
    class func viewHeight(width: CGFloat) -> CGFloat {
        return sizingView.avatarImageViewHeight + sizingView.customSpacing + sizingView.nameLabel.sizeThatFits(CGSize.init(width: width, height: .greatestFiniteMagnitude)).height
    }
}
