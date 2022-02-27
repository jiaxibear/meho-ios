//
//  CompleteProfileViewStep1Controller.swift
//  meho-ios
//
//  Created by Meho Dev on 1/19/21.
//  Copyright © 2021 Meho. All rights reserved.
//

import UIKit
import AWSMobileClient
import FirebaseAnalytics

class CompleteProfileViewStep1Controller: UIViewController, UITextFieldDelegate, MehoAnalytics {

    // MARK: - Constants
    private let nextButtonWidth = CGFloat(200)
    private let nextButtonHeight = CGFloat(40)
    private let nextButtonCornerRadius = CGFloat(6)
    private let nextButtonBottomMargin = CGFloat(80)
    private let welcomeLabelFontSize = CGFloat(26)
    private let welcomeLabelTopMargin = CGFloat(68)
    private let nicknameTextFieldFontSize = CGFloat(24)
    private let nicknameTextFieldTopMargin = CGFloat(84)
    private let nicknameTextFieldBottomLineLeadingTrailingMargin = CGFloat(32)
    private let nicknameTextFieldBottomLineHeight = CGFloat(1)
    private let nicknameTextFieldBottomLineTopMargin = CGFloat(4)
    private let imageViewWidth = CGFloat(276)
    private let imageViewHeight = CGFloat(232)
    private let imageViewTopMargin = CGFloat(18)

    // MARK: - Properties
    // MARK: Model
    private let userDataFecther = UserDataFetcher.shared

    // MARK: UI
    private lazy var imageView: UIImageView = {
        let image = UIImage.init(named: "onboarding_welcome")
        let imageView = UIImageView.init(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()

    private lazy var nextButton: UIButton = {
        let nextButton = UIButton.init(frame: .zero)
        nextButton.isEnabled = false
        nextButton.setTitle(NSLocalizedString("NextButtonTitle", comment: ""), for: .normal)
        nextButton.backgroundColor = .lightBlueGrey
        nextButton.setTitleColor(.white, for: .disabled)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = nextButtonCornerRadius
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        return nextButton
    } ()

    private lazy var welcomeLabel: UILabel = {
        let welcomeLabel = UILabel.init(frame: .zero)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.textColor = .darkGrayTwo
        var welcomeLabelFont = UIFont.systemFont(ofSize: welcomeLabelFontSize, weight: .regular)
        if let welcomeLabelFontDescriptor = welcomeLabelFont.fontDescriptor.withDesign(.rounded) {
            welcomeLabelFont = UIFont.init(descriptor: welcomeLabelFontDescriptor, size: welcomeLabelFontSize)
        }
        welcomeLabel.font = welcomeLabelFont
        welcomeLabel.text = NSLocalizedString("UserDefaultNickname", comment: "")
        return welcomeLabel
    } ()

    private lazy var nicknameTextField: UITextField = {
        let nicknameTextField = UITextField.init(frame: .zero)
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        nicknameTextField.backgroundColor = .clear
        nicknameTextField.textAlignment = .center
        nicknameTextField.delegate = self
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        var nicknameTextFieldPlaceholderFont = UIFont.systemFont(ofSize: nicknameTextFieldFontSize, weight: .light)
        if let nicknameTextFieldPlaceholderFontDescriptor = nicknameTextFieldPlaceholderFont.fontDescriptor.withDesign(.rounded) {
            nicknameTextFieldPlaceholderFont = UIFont.init(descriptor: nicknameTextFieldPlaceholderFontDescriptor, size: nicknameTextFieldFontSize)
        }
        let attributes = [
            NSAttributedString.Key.paragraphStyle: centeredParagraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.palePurple,
            NSAttributedString.Key.font : nicknameTextFieldPlaceholderFont
        ]
        let attributedPlaceholder = NSAttributedString(string: NSLocalizedString("CreateNicknameText", comment: ""), attributes: attributes)
        nicknameTextField.attributedPlaceholder = attributedPlaceholder
        var nicknameTextFieldFont = UIFont.systemFont(ofSize: nicknameTextFieldFontSize, weight: .medium)
        if let nicknameTextFieldFontDescriptor = nicknameTextFieldFont.fontDescriptor.withDesign(.rounded) {
            nicknameTextFieldFont = UIFont.init(descriptor: nicknameTextFieldFontDescriptor, size: nicknameTextFieldFontSize)
        }
        nicknameTextField.font = nicknameTextFieldFont
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return nicknameTextField
    } ()

    private lazy var nicknameTextFieldBottomLine: UIView = {
        let nicknameTextFieldBottomLine = UIView.init(frame: .zero)
        nicknameTextFieldBottomLine.translatesAutoresizingMaskIntoConstraints = false
        nicknameTextFieldBottomLine.backgroundColor = .lightBlueGrey
        return nicknameTextFieldBottomLine
    } ()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    } ()

    private lazy var scrollContentView: UIView = {
        let scrollContentView = UIView.init();
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        return scrollContentView
    } ()

    private lazy var nextButtonBottomConstraint: NSLayoutConstraint = {
        return nextButton.bottomAnchor.constraint(equalTo:scrollContentView.bottomAnchor, constant: -nextButtonBottomMargin)
    } ()

    private lazy var heightConstraint: NSLayoutConstraint = {
        let heightConstraint = scrollContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightConstraint.priority = .defaultLow
        return heightConstraint
    } ()

    private var keyboardHeight: CGFloat?

    // MARK: MehoAnalytics
    let screenName = "p_meho_onboarding_nickname"
    let screenClass =  "p_meho_onboarding"

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(welcomeLabel)
        scrollContentView.addSubview(nextButton)
        scrollContentView.addSubview(nicknameTextField)
        scrollContentView.addSubview(nicknameTextFieldBottomLine)
        scrollContentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            heightConstraint,

            welcomeLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: welcomeLabelTopMargin),
            welcomeLabel.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),

            nextButton.widthAnchor.constraint(equalToConstant: nextButtonWidth),
            nextButton.heightAnchor.constraint(equalToConstant: nextButtonHeight),
            nextButton.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            nextButtonBottomConstraint,

            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth),
            imageView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: imageViewTopMargin),

            nicknameTextField.leadingAnchor.constraint(equalTo: nicknameTextFieldBottomLine.leadingAnchor),
            nicknameTextField.trailingAnchor.constraint(equalTo: nicknameTextFieldBottomLine.trailingAnchor),
            nicknameTextField.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            nicknameTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: nicknameTextFieldTopMargin),

            nicknameTextFieldBottomLine.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: nicknameTextFieldBottomLineLeadingTrailingMargin),
            nicknameTextFieldBottomLine.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -nicknameTextFieldBottomLineLeadingTrailingMargin),
            nicknameTextFieldBottomLine.heightAnchor.constraint(equalToConstant: nicknameTextFieldBottomLineHeight),
            nicknameTextFieldBottomLine.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: nicknameTextFieldBottomLineTopMargin)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logScreenViewEvent(viewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = NSLocalizedString("completeProfileStep1Title", comment: "")
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    // MARK: - Private
    @objc
    func didTapNextButton() {
        guard let userID = AWSMobileClient.default().userSub, let nickName = nicknameTextField.text else {
            return
        }

        userDataFecther.updateUser(id: userID, username: nickName) { (basicUser, error) in
            DispatchQueue.main.async {
                self.title = ""
                self.navigationController?.pushViewController(CompleteProfileViewStep2Controller.init(goals: nil, isSingleStep: false), animated: true)
            }
        }
    }

    @objc
    func textFieldDidChange() {
        if let nickName = nicknameTextField.text, nickName.count > 0 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .skyBlue
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightBlueGrey
        }
    }

    @objc
    func keyboardWillShow(_ notification: Notification) {
        if keyboardHeight == nil {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        guard let keyboardHeight = keyboardHeight else {
            return
        }

        heightConstraint.constant = keyboardHeight
        nextButtonBottomConstraint.constant -= keyboardHeight
        scrollView.contentOffset = CGPoint.init(x: 0, y: keyboardHeight)
    }

    @objc
    func keyboardWillHide(_ notification: Notification) {
        heightConstraint.constant = 0
        nextButtonBottomConstraint.constant = -nextButtonBottomMargin
        scrollView.contentOffset = .zero
    }

}
