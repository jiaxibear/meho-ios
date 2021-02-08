//
//  ProfilePhotoViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 1/12/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit
import InitialsImageView
import PhotosUI
import Amplify
import AWSMobileClient

class ProfilePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    private var userPhoto: UIImage?

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
        takePhotoButton.addTarget(self, action: #selector(didTapTakePhotoButton), for: .touchUpInside)
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
        uploadPhotoButton.addTarget(self, action: #selector(didTapUploadPhotoButton), for: .touchUpInside)
        return uploadPhotoButton
    } ()

    // MARK: - UIViewController
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.bounds.width / 2
        if userName != nil && userPhoto == nil {
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
        saveBarButtonItem.isEnabled = false
        navigationItem.rightBarButtonItem = saveBarButtonItem
        if let navigationBar = navigationController?.navigationBar {
            navigationItem.standardAppearance = navigationBar.standardAppearance
            navigationItem.scrollEdgeAppearance = navigationBar.scrollEdgeAppearance
            navigationItem.standardAppearance?.titleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
            navigationItem.scrollEdgeAppearance?.titleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
        }

        if let saveBarButtonItemFontDescriptor = UIFont.systemFont(ofSize: saveButtonFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            saveBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(descriptor: saveBarButtonItemFontDescriptor, size: saveButtonFontSize)], for: .normal)
        }
        navigationController?.setNavigationBarHidden(false, animated: true)

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
        super.viewWillDisappear(animated)
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = .white
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationBar = navigationController?.navigationBar, presentedViewController == nil {
            navigationBar.tintColor = .wisteriaPurple
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[.editedImage] as? UIImage {
                self.profilePhotoImageView.image = image
                self.profilePhotoImageView.layer.borderWidth = 0
                self.userPhoto = image
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }

    @objc
    func didTapSaveButton() {
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        guard let userPhotoData = userPhoto?.pngData() else {
            return
        }
        let newProfilePhotoKey = userID + "_profilePhoto" + String(Date.init().timeIntervalSince1970)
        let options = StorageUploadDataRequest.Options(accessLevel: .protected)
        Amplify.Storage.uploadData(key: newProfilePhotoKey, data: userPhotoData, options: options) { (result) in
            switch result {
            case .success(_):
                UserDataFetcher.shared.updateUser(id: userID, avatarKey: newProfilePhotoKey) { (basicUser, error) in 
                    if error == nil {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                break
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                break
            }
        }
    }

    @objc
    func didTapTakePhotoButton() {
        let imagePickerController = UIImagePickerController.init()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc
    func didTapUploadPhotoButton() {
        let imagePickerController = UIImagePickerController.init()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
}
