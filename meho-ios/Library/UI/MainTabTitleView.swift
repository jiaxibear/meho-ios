//
//  MainTabTitleView.swift
//  meho-ios
//
//  Created by Jiaxi Xiong on 4/26/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient

class MainTabTitleView: UIView {

    // MARK: - Constants
    private let dummypProfileImageName = "no_profile_pic"
    private let titleLabelFontSize = CGFloat(34)
    private let titleLableTopMargin = CGFloat(8)
    private let viewHeight = CGFloat(40)
    private let profileButtonFontSize = CGFloat(24)

    // MARK: - Properties
    private let userDataFetcher = UserDataFetcher.shared
    private weak var delegate: TriggerProfileViewDelegate?

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.textColor = .wisteriaPurple
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .white
        if let fontDescriptor = UIFont.systemFont(ofSize: titleLabelFontSize, weight: .medium).fontDescriptor.withDesign(.rounded) {
            titleLabel.font = UIFont.init(descriptor: fontDescriptor, size: titleLabelFontSize)
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    } ()

    private lazy var profilePhotoImageView: WebImageView = {
        let profilePhotoImageView = WebImageView.init(frame: .zero)
        let profileImage = UIImage.init(named:dummypProfileImageName)
        profilePhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        profilePhotoImageView.image = profileImage
        profilePhotoImageView.isUserInteractionEnabled = true
        profilePhotoImageView.layer.masksToBounds = true
        profilePhotoImageView.layer.cornerRadius = viewHeight / 2
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapProfilePhotoImageView))
        profilePhotoImageView.addGestureRecognizer(tapGestureRecognizer)
        return profilePhotoImageView
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

        addSubview(titleLabel)
        addSubview(profilePhotoImageView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: titleLableTopMargin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            profilePhotoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            profilePhotoImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            profilePhotoImageView.heightAnchor.constraint(equalToConstant: viewHeight),
            profilePhotoImageView.widthAnchor.constraint(equalToConstant: viewHeight)
        ])

        guard let userID = AWSMobileClient.default().userSub else {
            return
        }

        userDataFetcher.getUser(userId: userID) { (basicUser, error) in
            if error == nil, let currentUser = basicUser {
                self.updateProfilePhoto(basicUser: currentUser)
            }
        }
        userDataFetcher.userSignal.subscribe(with: self) { (basicUser) in
            self.updateProfilePhoto(basicUser: basicUser)
        }
    }

    public func setTitleText(text: String) {
        titleLabel.text = text
    }

    public func getViewHeight() -> CGFloat {
        return viewHeight
    }

    func setDelegate(delegate: TriggerProfileViewDelegate) {
        self.delegate = delegate
    }

    @objc
    private func didTapProfilePhotoImageView() {
        delegate?.MainTitleViewDidTapProfileImage()
    }

    private func updateProfilePhoto(basicUser: BasicUser) {
        if let avatarImageKey = basicUser.avatarImageKey {
            self.profilePhotoImageView.imageKey = avatarImageKey
        } else {
            let currentUserName = basicUser.username
            if currentUserName != basicUser.email {
                DispatchQueue.main.async {
                    var textAttributes: [NSAttributedString.Key : AnyObject] = [.foregroundColor: UIColor.white]
                    if let profileImageViewFontDescriptor = UIFont.systemFont(ofSize: self.profileButtonFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
                        textAttributes[.font] = UIFont.init(descriptor: profileImageViewFontDescriptor, size: self.profileButtonFontSize)
                    } else {
                        textAttributes[.font] = UIFont.systemFont(ofSize: self.profileButtonFontSize, weight: .semibold)
                    }
                    self.profilePhotoImageView.setImageForName(currentUserName, backgroundColor: .greenBlue, circular: true, textAttributes: textAttributes, gradient: false)
                }
            }
        }
    }
}

protocol TriggerProfileViewDelegate : AnyObject {
    func MainTitleViewDidTapProfileImage()
}
