//
//  UpdateNicknameViewController.swift
//  meho-ios
//
//  Created by Meho Dev on 11/19/20.
//  Copyright © 2020 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

class UpdateNicknameViewController: UIViewController, MehoAnalytics {

    // MARK: - Constants
    private let changeNicknameLabelFontSize = CGFloat(16)
    private let changeNicknameTextFieldFontSize = CGFloat(16)
    private let changeNicknameTextFieldBackgroundColorAlpha = CGFloat(0.1)
    private let changeNicknameTextFieldTopMargin = CGFloat(16)
    private let changeNicknameTextFieldCornerRadius = CGFloat(2)
    private let changeNicknameTextFieldHeight = CGFloat(54)
    private let saveButtonTopMargin = CGFloat(36)
    private let saveButtonHeight = CGFloat(50)
    private let stackViewTopMargin = CGFloat(48)
    private let stackViewLeadingMargin = CGFloat(26)
    private let stackViewTrailingMargin = CGFloat(50)
    private let saveButtonLeadingTrailingMargin = CGFloat(58)

    // MARK: - Properties
    private lazy var changeNicknameLabel: UILabel = {
        let changeNicknameLabel = UILabel.init(frame: .zero)
        changeNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        changeNicknameLabel.textColor = .darkGrayTwo
        if let changeNicknameLabelFontDescriptor = UIFont.systemFont(ofSize: changeNicknameLabelFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            changeNicknameLabel.font = UIFont.init(descriptor: changeNicknameLabelFontDescriptor, size: changeNicknameLabelFontSize)
        }
        changeNicknameLabel.text = NSLocalizedString("ChangeNicknameTitle", comment: "")
        return changeNicknameLabel
    } ()

    private lazy var changeNicknameTextField: UITextField = {
        let changeNicknameTextField = UITextFieldPadding.init(frame: .zero)
        changeNicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        changeNicknameTextField.backgroundColor = UIColor.skyBlue.withAlphaComponent(changeNicknameTextFieldBackgroundColorAlpha)
        changeNicknameTextField.textColor = .darkGrayTwo
        if let changeNicknameTextFieldFontDescriptor = UIFont.systemFont(ofSize: changeNicknameTextFieldFontSize, weight: .light).fontDescriptor.withDesign(.rounded) {
            changeNicknameTextField.font = UIFont.init(descriptor: changeNicknameTextFieldFontDescriptor, size: changeNicknameTextFieldFontSize)
        }
        changeNicknameTextField.layer.cornerRadius = changeNicknameTextFieldCornerRadius
        changeNicknameTextField.clipsToBounds = true
        changeNicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return changeNicknameTextField
    } ()

    private lazy var saveButton: UIButton = {
        let saveButton = UIButton.init(frame: .zero)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle(NSLocalizedString("SaveButtonTitle", comment: ""), for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .lightBlueGrey
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        return saveButton
    } ()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [changeNicknameLabel, changeNicknameTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.setCustomSpacing(changeNicknameTextFieldTopMargin, after: changeNicknameLabel)
        return stackView
    } ()

    private let userDataFetcher = UserDataFetcher.shared

    // MARK: MehoAnalytics
    let screenName = "p_meho_profiles_setting_change_nickname"
    let screenClass =  "p_meho_profiles_setting"

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("ChangeNicknameTitle", comment: "")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init")
    }

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(stackView)
        view.addSubview(saveButton)
        let layoutMarginsGuide = view.layoutMarginsGuide
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: stackViewTopMargin).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: stackViewLeadingMargin).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -stackViewTrailingMargin).isActive = true
        changeNicknameTextField.heightAnchor.constraint(equalToConstant: changeNicknameTextFieldHeight).isActive = true
        saveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: stackViewTopMargin).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: saveButtonHeight).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: saveButtonLeadingTrailingMargin).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -saveButtonLeadingTrailingMargin).isActive = true

        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        userDataFetcher.getUser(userId: userID) { (basicUser, error) in
            self.changeNicknameTextField.text = basicUser?.username
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    // MARK: - Private
    @objc
    func textFieldDidChange() {
        saveButton.isEnabled = true
        saveButton.backgroundColor = .skyBlue
    }

    @objc
    func didTapSaveButton() {
        guard let userID = AWSMobileClient.default().userSub else {
            return
        }
        userDataFetcher.updateUser(id: userID, username: changeNicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)) { (basicUser, error) in
            self.navigationController?.popViewController(animated: true)
        }
    }
}
