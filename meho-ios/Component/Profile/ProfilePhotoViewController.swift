//
//  ProfilePhotoViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 1/12/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit
import InitialsImageView

class ProfilePhotoViewController: UIViewController {

    // MARK: - Constants
    private let defaultProfileImageName = "no_profile_pic"
    private let buttonLeadingTrailingMargin = CGFloat(70)
    private let buttonBottomMargin = CGFloat(32)
    private let profilePhotoImageViewLeadingTrailingMargin = CGFloat(32)
    private let buttonFontSize = CGFloat(16)
    private let backBarButtonItemImageName = "arrow.left"
    private let navigationBarTitleFontSize = CGFloat(18)
    private let saveButtonFontSize = CGFloat(16)
    private let profileImageViewFontSize = CGFloat(250)

    private let userName: String?

    // MARK: - Init
    @available(*, unavailable)
        init() {
        fatalError("Use init(profilePhoto: UIImage)")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(profilePhoto: UIImage)")
    }

    init(profilePhoto: UIImage? = nil, userName: String? = nil) {
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
        if profilePhoto != nil {
            profilePhotoImageView.image = profilePhoto
        }
    }

    // MARK: - Properties
    private lazy var profilePhotoImageView: UIImageView = {
        let profilePhotoImageView = UIImageView.init(frame: .zero)
        profilePhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        profilePhotoImageView.layer.masksToBounds = true
        let profileImage = UIImage.init(named:defaultProfileImageName)
        profilePhotoImageView.image = profileImage
        return profilePhotoImageView
    } ()

    private lazy var takePhotoButton: UIButton = {
        let takePhotoButton = ImageTopAndTitleDownButton.init(frame: .zero)
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.setTitle(NSLocalizedString("takePhotoButtonTitle", comment: ""), for: .normal)
        takePhotoButton.backgroundColor = .clear
        takePhotoButton.setTitleColor(.white, for: .normal)
        if let takePhotoButtonFontDescriptor = UIFont.systemFont(ofSize: buttonFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            takePhotoButton.titleLabel?.font = UIFont.init(descriptor: takePhotoButtonFontDescriptor, size: buttonFontSize)
        }
        let takePhotoButtonImage = UIImage.init(named: "profile_photo_camara")
        takePhotoButton.setImage(takePhotoButtonImage, for: .normal)
        takePhotoButton.imageView?.contentMode = .scaleAspectFit
        return takePhotoButton
    } ()

    private lazy var uploadPhotoButton: UIButton = {
        let uploadPhotoButton = ImageTopAndTitleDownButton.init(frame: .zero)
        uploadPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        uploadPhotoButton.setTitle(NSLocalizedString("uploadPhotoButtonTitle", comment: ""), for: .normal)
        uploadPhotoButton.backgroundColor = .clear
        uploadPhotoButton.setTitleColor(.white, for: .normal)
        if let uploadPhotoButtonFontDescriptor = UIFont.systemFont(ofSize: buttonFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            uploadPhotoButton.titleLabel?.font = UIFont.init(descriptor: uploadPhotoButtonFontDescriptor, size: buttonFontSize)
        }
        let uploadPhotoButtonImage = UIImage.init(named: "profile_photo_upload")
        uploadPhotoButton.setImage(uploadPhotoButtonImage, for: .normal)
        uploadPhotoButton.imageView?.contentMode = .scaleAspectFit
        return uploadPhotoButton
    } ()

    // MARK: - UIViewController
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.bounds.width / 2
        if userName != nil {
                var textAttributes: [NSAttributedString.Key : AnyObject] = [.foregroundColor: UIColor.white]
                if let profileImageViewFontDescriptor = UIFont.systemFont(ofSize: profileImageViewFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
                    textAttributes[.font] = UIFont.init(descriptor: profileImageViewFontDescriptor, size: self.profileImageViewFontSize)
                } else {
                    textAttributes[.font] = UIFont.systemFont(ofSize: self.profileImageViewFontSize, weight: .semibold)
                }
                profilePhotoImageView.setImageForName(userName!, backgroundColor: .greenBlue, circular: true, textAttributes: textAttributes, gradient: false)
                profilePhotoImageView.layer.borderColor = UIColor.white.cgColor
                profilePhotoImageView.layer.borderWidth = 2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(takePhotoButton)
        view.addSubview(uploadPhotoButton)
        view.addSubview(profilePhotoImageView)
        view.backgroundColor = .textCharcoalGrey
        title = NSLocalizedString("ProfilePhotoTitle", comment: "")
        let saveBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("SaveButtonTitle", comment: ""), style: .plain, target: self, action: #selector(didTapSaveButton))
        navigationItem.rightBarButtonItem = saveBarButtonItem
        if let saveBarButtonItemFontDescriptor = UIFont.systemFont(ofSize: saveButtonFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            saveBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(descriptor: saveBarButtonItemFontDescriptor, size: saveButtonFontSize)], for: .normal)
        }

        let layoutMarginsGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            takePhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonLeadingTrailingMargin),
            takePhotoButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -buttonBottomMargin),

            uploadPhotoButton.bottomAnchor.constraint(equalTo: takePhotoButton.bottomAnchor),
            uploadPhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -buttonLeadingTrailingMargin),

            profilePhotoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: profilePhotoImageViewLeadingTrailingMargin),
            profilePhotoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -profilePhotoImageViewLeadingTrailingMargin),
            profilePhotoImageView.heightAnchor.constraint(equalTo: profilePhotoImageView.widthAnchor),
            profilePhotoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = .white
            navigationBar.standardAppearance.titleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
            navigationBar.scrollEdgeAppearance?.titleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = .wisteriaPurple
            navigationBar.standardAppearance.titleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.wisteriaPurple
            navigationBar.scrollEdgeAppearance?.titleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.wisteriaPurple
        }
    }

    @objc
    func didTapSaveButton() {

    }
}
